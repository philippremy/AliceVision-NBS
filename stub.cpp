//
// Created by Philipp Remy on 01.06.26.
//

#include <boost/test/unit_test_suite.hpp>

/**
 * @brief Required by Boost when linking Boost::unit_test_framework as a static
 *        library
 */
boost::unit_test::test_suite* init_unit_test_suite(int argc, char** argv)
{
    return BOOST_TEST_SUITE("STUB");
}
