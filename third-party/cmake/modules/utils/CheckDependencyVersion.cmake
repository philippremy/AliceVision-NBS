# =============================================================================
# VersionRange.cmake - Provides a helper function to verify dependency versions
#
# Semver-ish parsing with prefix support:
# - "3" means any 3.x.y
# - "3.5" means any 3.5.y
# - "3.5.7" means exactly 3.5.7
#
# Range syntax:
#   "1.2"               -> >= 1.2.0 AND < 1.3.0
#   "1.2..."            -> >= 1.2.0
#   "1.2...1.2.5"       -> >= 1.2.0 AND < 1.2.5
#   "1.2...<2"          -> >= 1.2.0 AND < 2.0.0
#   "1.2...<=3"         -> >= 1.2.0 AND < 4.0.0
#   "...<3.4"           -> < 3.4.0
#   "...<=3.5"          -> < 3.6.0
# =============================================================================

include_guard(GLOBAL)

function(_vr_strip_ws in out)
  string(REGEX REPLACE "[ \t\r\n]" "" _s "${in}")
  set(${out} "${_s}" PARENT_SCOPE)
endfunction()

# Parse a version token into components and count (1..3).
# Accepts digits and dots only.
# Any components beyond patch level are discarded.
function(_vr_parse_token token out_count out_major out_minor out_patch)
  if("${token}" STREQUAL "")
    message(FATAL_ERROR "_vr_parse_token: empty token")
  endif()

  # Accept one or more numeric components separated by dots.
  if(NOT "${token}" MATCHES "^[0-9]+(\\.[0-9]+)*$")
    message(FATAL_ERROR "_vr_parse_token: invalid version token '${token}'")
  endif()

  string(REPLACE "." ";" _parts "${token}")
  list(LENGTH _parts _len)

  # Truncate to at most 3 components.
  if(_len GREATER 3)
    list(SUBLIST _parts 0 3 _parts)
    set(_len 3)
  endif()

  list(GET _parts 0 _maj)
  set(_min 0)
  set(_pat 0)

  if(_len GREATER_EQUAL 2)
    list(GET _parts 1 _min)
  endif()

  if(_len GREATER_EQUAL 3)
    list(GET _parts 2 _pat)
  endif()

  set(${out_count} "${_len}" PARENT_SCOPE)
  set(${out_major} "${_maj}" PARENT_SCOPE)
  set(${out_minor} "${_min}" PARENT_SCOPE)
  set(${out_patch} "${_pat}" PARENT_SCOPE)
endfunction()

# Normalize token to a 3-component numeric version string: M.m.p
function(_vr_token_to_triplet token out_triplet out_count)
  _vr_parse_token("${token}" _c _maj _min _pat)
  set(${out_triplet} "${_maj}.${_min}.${_pat}" PARENT_SCOPE)
  set(${out_count} "${_c}" PARENT_SCOPE)
endfunction()

# Compute the "next prefix" of a token:
#   3       -> 4.0.0
#   3.5     -> 3.6.0
#   3.5.7   -> 3.5.8  (not used for our prefix ranges; but implemented for completeness)
function(_vr_next_prefix token out_triplet)
  _vr_parse_token("${token}" _c _maj _min _pat)

  if(_c EQUAL 1)
    math(EXPR _maj2 "${_maj} + 1")
    set(${out_triplet} "${_maj2}.0.0" PARENT_SCOPE)
  elseif(_c EQUAL 2)
    math(EXPR _min2 "${_min} + 1")
    set(${out_triplet} "${_maj}.${_min2}.0" PARENT_SCOPE)
  else()
    math(EXPR _pat2 "${_pat} + 1")
    set(${out_triplet} "${_maj}.${_min}.${_pat2}" PARENT_SCOPE)
  endif()
endfunction()

# For exact tokens, decide whether they represent a prefix-range (short token) or a single point (3-part).
# Outputs:
#   has_min/min always set
#   has_max/max set for prefix-range and for full exact
#   max_inclusive used only for full exact (<= max), otherwise exclusive (< max)
function(_vr_expand_exact_token token
    out_has_min out_min
    out_has_max out_max
    out_max_inclusive
)
  _vr_token_to_triplet("${token}" _min_triplet _count)

  set(_has_min TRUE)
  set(_min "${_min_triplet}")

  if(_count LESS 3)
    # "3" => [3.0.0, 4.0.0)
    # "3.5" => [3.5.0, 3.6.0)
    _vr_next_prefix("${token}" _next)
    set(_has_max TRUE)
    set(_max "${_next}")
    set(_max_inclusive FALSE) # exclusive upper
  else()
    # "3.5.7" => exact point
    set(_has_max TRUE)
    set(_max "${_min_triplet}")
    set(_max_inclusive TRUE)
  endif()

  set(${out_has_min} "${_has_min}" PARENT_SCOPE)
  set(${out_min} "${_min}" PARENT_SCOPE)
  set(${out_has_max} "${_has_max}" PARENT_SCOPE)
  set(${out_max} "${_max}" PARENT_SCOPE)
  set(${out_max_inclusive} "${_max_inclusive}" PARENT_SCOPE)
endfunction()

# Expand an upper bound token depending on operator.
# - "< token": normalize token to triplet, exclusive.
# - "<= token":
#     * if short token (count<3): convert to next prefix and make it exclusive (< nextprefix)
#       so "<=3" becomes "<4.0.0" which includes all 3.x.y
#     * if full token (count=3): inclusive <= token
function(_vr_expand_upper_bound op token out_has_max out_max out_max_inclusive)
  if(NOT (op STREQUAL "<" OR op STREQUAL "<="))
    message(FATAL_ERROR "_vr_expand_upper_bound: op must be < or <=")
  endif()

  _vr_token_to_triplet("${token}" _triplet _count)

  set(_has_max TRUE)

  if(op STREQUAL "<")
    set(_max "${_triplet}")
    set(_max_inclusive FALSE)
  else()
    # <=
    if(_count LESS 3)
      _vr_next_prefix("${token}" _next)
      set(_max "${_next}")
      set(_max_inclusive FALSE) # <=3 is equivalent to <4.0.0 for prefix semantics
    else()
      set(_max "${_triplet}")
      set(_max_inclusive TRUE)
    endif()
  endif()

  set(${out_has_max} "${_has_max}" PARENT_SCOPE)
  set(${out_max} "${_max}" PARENT_SCOPE)
  set(${out_max_inclusive} "${_max_inclusive}" PARENT_SCOPE)
endfunction()

function(vr_parse range_string)
  cmake_parse_arguments(VR
      ""
      "OUT_MIN;OUT_HAS_MIN;OUT_MAX;OUT_HAS_MAX;OUT_MAX_INCLUSIVE;OUT_IS_EXACT;OUT_EXACT"
      ""
      ${ARGN}
  )

  if(NOT VR_OUT_MIN OR NOT VR_OUT_HAS_MIN OR
      NOT VR_OUT_MAX OR NOT VR_OUT_HAS_MAX OR
      NOT VR_OUT_MAX_INCLUSIVE OR
      NOT VR_OUT_IS_EXACT OR NOT VR_OUT_EXACT)
    message(FATAL_ERROR
        "vr_parse: missing output vars. Usage:\n"
        "  vr_parse(<range>\n"
        "           OUT_MIN <v> OUT_HAS_MIN <v>\n"
        "           OUT_MAX <v> OUT_HAS_MAX <v>\n"
        "           OUT_MAX_INCLUSIVE <v>\n"
        "           OUT_IS_EXACT <v> OUT_EXACT <v>)"
    )
  endif()

  _vr_strip_ws("${range_string}" _r)

  set(_has_min FALSE)
  set(_min "")
  set(_has_max FALSE)
  set(_max "")
  set(_max_inclusive FALSE)
  set(_is_exact FALSE)
  set(_exact "")

  if(_r STREQUAL "")
    message(FATAL_ERROR "vr_parse: empty range string")
  endif()

  string(FIND "${_r}" "..." _dots_pos)
  if(_dots_pos EQUAL -1)
    # Exact token, but semver-ish: 3 -> 3.x.y, 3.5 -> 3.5.y, 3.5.7 -> exact
    set(_is_exact TRUE)
    set(_exact "${_r}")
    _vr_expand_exact_token("${_r}" _has_min _min _has_max _max _max_inclusive)
  else()
    # Split at the first "..."
    string(SUBSTRING "${_r}" 0 ${_dots_pos} _left)
    math(EXPR _rhs_pos "${_dots_pos} + 3")
    string(SUBSTRING "${_r}" ${_rhs_pos} -1 _right)

    # Min (always inclusive)
    if(NOT _left STREQUAL "")
      _vr_token_to_triplet("${_left}" _min _min_count)
      set(_has_min TRUE)
    endif()

    # Max (optional)
    if(_right STREQUAL "")
      set(_has_max FALSE)
    else()
      if(_right MATCHES "^<=.+")
        string(SUBSTRING "${_right}" 2 -1 _tok)
        _vr_expand_upper_bound("<=" "${_tok}" _has_max _max _max_inclusive)
      elseif(_right MATCHES "^<.+")
        string(SUBSTRING "${_right}" 1 -1 _tok)
        _vr_expand_upper_bound("<" "${_tok}" _has_max _max _max_inclusive)
      else()
        # Bare upper => exclusive upper bound, normalized to triplet
        _vr_token_to_triplet("${_right}" _max _max_count)
        set(_has_max TRUE)
        set(_max_inclusive FALSE)
      endif()

      if(_has_max AND _max STREQUAL "")
        message(FATAL_ERROR "vr_parse: missing maximum version in '${range_string}'")
      endif()
    endif()
  endif()

  # Sanity check: if both bounds exist, ensure min <= max (as numbers).
  if(_has_min AND _has_max)
    if(_min VERSION_GREATER _max)
      message(FATAL_ERROR
          "vr_parse: invalid range '${range_string}': min '${_min}' is greater than max '${_max}'"
      )
    endif()
  endif()

  set(${VR_OUT_MIN} "${_min}" PARENT_SCOPE)
  set(${VR_OUT_HAS_MIN} "${_has_min}" PARENT_SCOPE)
  set(${VR_OUT_MAX} "${_max}" PARENT_SCOPE)
  set(${VR_OUT_HAS_MAX} "${_has_max}" PARENT_SCOPE)
  set(${VR_OUT_MAX_INCLUSIVE} "${_max_inclusive}" PARENT_SCOPE)
  set(${VR_OUT_IS_EXACT} "${_is_exact}" PARENT_SCOPE)
  set(${VR_OUT_EXACT} "${_exact}" PARENT_SCOPE)
endfunction()

function(alicevision_check_dependency_version range_string version out_var)
  if(NOT out_var)
    message(FATAL_ERROR "vr_contains: missing <out_bool_var>")
  endif()

  # Normalize tested version to a triplet too (so "3.4" becomes "3.4.0")
  _vr_token_to_triplet("${version}" _v _vcount)

  vr_parse("${range_string}"
      OUT_MIN _min OUT_HAS_MIN _has_min
      OUT_MAX _max OUT_HAS_MAX _has_max
      OUT_MAX_INCLUSIVE _max_incl
      OUT_IS_EXACT _is_exact OUT_EXACT _exact
  )

  set(_ok TRUE)

  if(_has_min)
    if("${_v}" VERSION_LESS "${_min}")
      set(_ok FALSE)
    endif()
  endif()

  if(_ok AND _has_max)
    if(_max_incl)
      if("${_v}" VERSION_GREATER "${_max}")
        set(_ok FALSE)
      endif()
    else()
      # exclusive upper
      if(NOT "${_v}" VERSION_LESS "${_max}")
        set(_ok FALSE)
      endif()
    endif()
  endif()

  set(${out_var} "${_ok}" PARENT_SCOPE)
endfunction()