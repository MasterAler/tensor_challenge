#pragma once

#include <cstddef>
#include <new>

struct Vec3
{
    float x;
    float y;
    float z;
};

class Vec3Allocator
{
public:
    static constexpr std::size_t CELL_ALIGN = 16;
    static constexpr std::size_t CELLS_PER_SEGMENT = 5;

    Vec3Allocator() = default;
    ~Vec3Allocator();

    Vec3Allocator(const Vec3Allocator&) = delete;
    Vec3Allocator& operator=(const Vec3Allocator&) = delete;
    Vec3Allocator(Vec3Allocator&&) = delete;
    Vec3Allocator& operator=(Vec3Allocator&&) = delete;

    Vec3* Allocate()
    {
        if (!free_)
            AddSegment();

        Cell* cell = free_;
        free_ = cell->next;
        return ::new (cell->storage) Vec3;
    }

    void Deallocate(Vec3* ptr) noexcept
    {
        ptr->~Vec3();
        free_ = ::new (static_cast<void*>(ptr)) Cell { free_ };
    }

private:
    union alignas(CELL_ALIGN) Cell
    {
        Cell* next;
        unsigned char storage[sizeof(Vec3)];
    };

    struct Segment
    {
        Cell cells[CELLS_PER_SEGMENT];
        Segment* next;
    };

    static_assert(sizeof(Cell) == CELL_ALIGN);
    static_assert(alignof(Cell) == CELL_ALIGN);
    static_assert(sizeof(Segment::cells) == CELLS_PER_SEGMENT * CELL_ALIGN);

    void AddSegment();

    Segment* segments_ = nullptr;
    Cell* free_ = nullptr;
};
