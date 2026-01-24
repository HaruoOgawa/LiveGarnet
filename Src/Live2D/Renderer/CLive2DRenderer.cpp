#include "CLive2DRenderer.h"

namespace livegarnet
{
	CLive2DRenderer::CLive2DRenderer(CLive2DModel* model):
		m_Model(model)
	{
	}

	CLive2DRenderer::~CLive2DRenderer()
	{
		m_TextureList.clear();
	}

	bool CLive2DRenderer::Initialize()
	{
		return true;
	}

	bool CLive2DRenderer::LoadTextures(api::IGraphicsAPI* pGraphicsAPI, const std::shared_ptr<ICubismModelSetting>& ModelSetting, const std::string& Directory)
	{
		return true;
	}

	bool CLive2DRenderer::Draw(CubismMatrix44& MVPMat)
	{
		return true;
	}
}