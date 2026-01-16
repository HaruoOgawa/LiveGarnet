#include "CLive2DMemoryAllocator.h"
#include <malloc.h>

namespace livegarnet
{
	CLive2DMemoryAllocator::CLive2DMemoryAllocator()
	{
	}

	CLive2DMemoryAllocator::~CLive2DMemoryAllocator()
	{
	}

	void* CLive2DMemoryAllocator::Allocate(const Live2D::Cubism::Framework::csmSizeType size)
	{
		return malloc(size);
	}

	void CLive2DMemoryAllocator::Deallocate(void* memory)
	{
		free(memory);
	}

	void* CLive2DMemoryAllocator::AllocateAligned(const Live2D::Cubism::Framework::csmSizeType size, const Live2D::Cubism::Framework::csmUint32 alignment)
	{
		size_t offset, shift, alignedAddress;
		void* allocation;
		void** preamble;

		offset = alignment - 1 + sizeof(void*);

		allocation = Allocate(size + static_cast<Live2D::Cubism::Framework::csmUint32>(offset));

		alignedAddress = reinterpret_cast<size_t>(allocation) + sizeof(void*);

		shift = alignedAddress % alignment;

		if (shift)
		{
			alignedAddress += (alignment - shift);
		}

		preamble = reinterpret_cast<void**>(alignedAddress);
		preamble[-1] = allocation;

		return reinterpret_cast<void*>(alignedAddress);
	}

	void CLive2DMemoryAllocator::DeallocateAligned(void* alignedMemory)
	{
		void** preamble;

		preamble = static_cast<void**>(alignedMemory);

		Deallocate(preamble[-1]);
	}
}