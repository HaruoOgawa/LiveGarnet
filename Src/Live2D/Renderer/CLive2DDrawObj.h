#pragma once

#include <Graphics/CDrawObj.h>
#include <glm/glm.hpp>
#include <Math/CubismMatrix44.hpp>

namespace livegarnet
{
	class CLive2DRenderer;

	class CLive2DDrawObj : public graphics::CDrawObj
	{
		Live2D::Cubism::Framework::CubismMatrix44 m_MVPMat;

		CLive2DRenderer* m_pRender;
	public:
		CLive2DDrawObj(int RenderQueue, float ToCameraDist, const Live2D::Cubism::Framework::CubismMatrix44& MVPMat, CLive2DRenderer* pRender);

		virtual ~CLive2DDrawObj() = default;

		virtual bool Draw() override;
	};
}