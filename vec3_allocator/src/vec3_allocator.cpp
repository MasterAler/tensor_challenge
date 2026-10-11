#include "vec3_allocator.h"

Vec3Allocator::~Vec3Allocator()
{
    while (segments_)
    {
        Segment* next = segments_->next;
        delete segments_;
        segments_ = next;
    }
}

void Vec3Allocator::AddSegment()
{
    Segment* segment = new Segment;
    segment->next = segments_;
    segments_ = segment;

    for (std::size_t i = 0; i + 1 < CELLS_PER_SEGMENT; ++i)
        segment->cells[i].next = &segment->cells[i + 1];
    segment->cells[CELLS_PER_SEGMENT - 1].next = free_;
    free_ = segment->cells;
}
