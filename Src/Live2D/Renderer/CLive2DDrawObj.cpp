#include "CLive2DDrawObj.h"
#include "CLive2DRenderer.h"

namespace livegarnet
{
	CLive2DDrawObj::CLive2DDrawObj(int RenderQueue, float ToCameraDist, const Live2D::Cubism::Framework::CubismMatrix44& MVPMat, CLive2DRenderer* pRender):
		graphics::CDrawObj(RenderQueue, ToCameraDist),
		m_MVPMat(MVPMat),
		m_pRender(pRender)
	{
	}

	bool CLive2DDrawObj::Draw()
	{
		if (!m_pRender) return true;

		if (!m_pRender->Draw(m_MVPMat)) return false;

		return true;
	}
}