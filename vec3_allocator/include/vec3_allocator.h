#pragma once

struct Vec3
{
    float x;
    float y;
    float z;
};

class Vec3Allocator
{
public:
    Vec3Allocator() = default;
    ~Vec3Allocator();

    Vec3* Allocate();
    void Deallocate(Vec3* ptr) noexcept;
};
