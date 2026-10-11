#include "vec3_allocator.h"

Vec3Allocator::~Vec3Allocator()
{
}

Vec3* Vec3Allocator::Allocate()
{
    return nullptr;
}

void Vec3Allocator::Deallocate(Vec3* ptr) noexcept
{
}
