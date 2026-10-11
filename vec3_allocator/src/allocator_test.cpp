#include <gtest/gtest.h>

#include <cstdint>
#include <cstdlib>
#include <new>
#include <set>

#include "vec3_allocator.h"

static std::size_t g_new_calls = 0;
static std::size_t g_live_blocks = 0;

void* operator new(std::size_t size)
{
    ++g_new_calls;
    ++g_live_blocks;
    if (void* p = std::malloc(size ? size : 1))
        return p;
    throw std::bad_alloc();
}

void operator delete(void* p) noexcept
{
    if (!p)
        return;
    --g_live_blocks;
    std::free(p);
}

void operator delete(void* p, std::size_t) noexcept
{
    operator delete(p);
}

bool is_aligned(const void* p)
{
    return reinterpret_cast<std::uintptr_t>(p) % 16 == 0;
}

struct AllocCounter
{
    AllocCounter()
        : calls(g_new_calls)
        , live(g_live_blocks)
    {
    }

    std::size_t NewCalls() const
    {
        return g_new_calls - calls;
    }

    std::size_t LiveBlocks() const
    {
        return g_live_blocks - live;
    }

    std::size_t calls;
    std::size_t live;
};

// ----------------------------------------------------

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

TEST(Allocator, Aligned)
{
    Vec3Allocator alloc;
    for (int i = 0; i < 1000; ++i)
        ASSERT_TRUE(is_aligned(alloc.Allocate())) << "i = " << i;
}

TEST(Allocator, ManySegments)
{
    const std::size_t N = Vec3Allocator::CELLS_PER_SEGMENT * 20 + 3;
    Vec3* ptrs[N];

    Vec3Allocator alloc;
    for (std::size_t i = 0; i < N; ++i)
    {
        ptrs[i] = alloc.Allocate();
        ptrs[i]->x = float(i);
        ptrs[i]->y = float(i) * 2;
        ptrs[i]->z = float(i) * 3;
    }

    std::set<std::uintptr_t> addrs;
    for (std::size_t i = 0; i < N; ++i)
    {
        EXPECT_EQ(ptrs[i]->x, float(i));
        EXPECT_EQ(ptrs[i]->y, float(i) * 2);
        EXPECT_EQ(ptrs[i]->z, float(i) * 3);
        addrs.insert(reinterpret_cast<std::uintptr_t>(ptrs[i]));
    }
    EXPECT_EQ(addrs.size(), N);

    auto it = addrs.begin();
    for (auto next = std::next(it); next != addrs.end(); ++it, ++next)
        EXPECT_GE(*next - *it, 16u);
}

TEST(Allocator, OneNewPerSegment)
{
    AllocCounter cnt;
    {
        Vec3Allocator alloc;
        for (std::size_t i = 0; i < Vec3Allocator::CELLS_PER_SEGMENT; ++i)
            alloc.Allocate();
        EXPECT_EQ(cnt.NewCalls(), 1u);

        alloc.Allocate();
        EXPECT_EQ(cnt.NewCalls(), 2u);
    }
}

TEST(Allocator, Reuse)
{
    Vec3Allocator alloc;
    Vec3* a = alloc.Allocate();
    alloc.Deallocate(a);
    EXPECT_EQ(alloc.Allocate(), a);

    Vec3* b = alloc.Allocate();
    Vec3* c = alloc.Allocate();
    alloc.Deallocate(b);
    alloc.Deallocate(c);
    EXPECT_EQ(alloc.Allocate(), c);
    EXPECT_EQ(alloc.Allocate(), b);
}

TEST(Allocator, ReuseNoNewCalls)
{
    const std::size_t N = Vec3Allocator::CELLS_PER_SEGMENT * 10;
    Vec3* ptrs[N];

    Vec3Allocator alloc;
    for (auto& p : ptrs)
        p = alloc.Allocate();

    AllocCounter cnt;
    for (int round = 0; round < 100; ++round)
    {
        for (std::size_t i = round % 2; i < N; i += 2)
            alloc.Deallocate(ptrs[i]);
        for (std::size_t i = round % 2; i < N; i += 2)
        {
            ptrs[i] = alloc.Allocate();
            ASSERT_TRUE(is_aligned(ptrs[i]));
        }
    }
    EXPECT_EQ(cnt.NewCalls(), 0u);
}

TEST(Allocator, NoLeaks)
{
    AllocCounter cnt;
    {
        Vec3Allocator alloc;
        for (int i = 0; i < 1003; ++i)
        {
            Vec3* v = alloc.Allocate();
            if (i % 3 == 0)
                alloc.Deallocate(v);
        }
        EXPECT_GT(cnt.LiveBlocks(), 0u);
    }
    EXPECT_EQ(cnt.LiveBlocks(), 0u);
}

TEST(Allocator, EmptyNoLeaks)
{
    AllocCounter cnt;
    {
        Vec3Allocator alloc;
    }
    EXPECT_EQ(cnt.NewCalls(), 0u);
    EXPECT_EQ(cnt.LiveBlocks(), 0u);
}
