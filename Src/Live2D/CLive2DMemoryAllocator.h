#pragma once

#include <ICubismAllocator.hpp>

namespace livegarnet
{
	class CLive2DMemoryAllocator : public Live2D::Cubism::Framework::ICubismAllocator
	{
	public:
		CLive2DMemoryAllocator();
		virtual ~CLive2DMemoryAllocator();

		void* Allocate(const Live2D::Cubism::Framework::csmSizeType size) override;
		void Deallocate(void* memory) override;

		void* AllocateAligned(const Live2D::Cubism::Framework::csmSizeType size, const Live2D::Cubism::Framework::csmUint32 alignment) override;
		void DeallocateAligned(void* alignedMemory) override;
	};
}