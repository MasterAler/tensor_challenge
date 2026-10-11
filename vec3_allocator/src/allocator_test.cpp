#include <gtest/gtest.h>

#include "vec3_allocator.h"

TEST(Allocator, Smoke)
{
    Vec3Allocator alloc;
    Vec3* v = alloc.Allocate();
    v->x = 1.f;
    v->y = 2.f;
    v->z = 3.f;
    EXPECT_EQ(v->y, 2.f);
    alloc.Deallocate(v);
}
