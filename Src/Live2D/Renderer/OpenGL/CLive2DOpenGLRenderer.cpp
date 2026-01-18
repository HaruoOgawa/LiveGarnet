#ifdef USE_OPENGL
#include "CLive2DOpenGLRenderer.h"
#include "../../CLive2DModel.h"

#include <LoadWorker/CFile.h>
#include <Rendering/OpenGL/CubismRenderer_OpenGLES2.hpp>
#include <GraphicsAPI/OpenGL/COpenGLAPI.h>
#include <GraphicsAPI/OpenGL/COpenGLTexture.h>

namespace livegarnet
{
	CLive2DOpenGLRenderer::CLive2DOpenGLRenderer(CLive2DModel* model):
		CLive2DRenderer(model)
	{
	}

	CLive2DOpenGLRenderer::~CLive2DOpenGLRenderer()
	{
	}

	bool CLive2DOpenGLRenderer::Initialize()
	{
		m_Model->CreateRenderer();

		return true;
	}

	bool CLive2DOpenGLRenderer::Draw()
	{
		// ƒ‚ƒfƒ‹‚Ì•`‰æ–½—ß‚ðŽÀs
		m_Model->GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->DrawModel();

		return true;
	}

	bool CLive2DOpenGLRenderer::LoadTextures(api::IGraphicsAPI* pGraphicsAPI, const std::shared_ptr<ICubismModelSetting>& ModelSetting, const std::string& Directory)
	{
		for (int TextureIndex = 0; TextureIndex < ModelSetting->GetTextureCount(); TextureIndex++)
		{
			std::string FileName = ModelSetting->GetTextureFileName(TextureIndex);
			if (FileName.empty()) continue;

			std::string Path = Directory + FileName;

			resource::CFile File = resource::CFile(Path);
			if (!File.LoadImmediate()) return false;

			auto Texture = pGraphicsAPI->CreateTexture();
			if (!Texture->Create(File.GetData())) return false;

			api::COpenGLTexture* pOpenGLTexture = static_cast<api::COpenGLTexture*>(Texture.get());
			if (!pOpenGLTexture) continue;

			m_Model->GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->BindTexture(TextureIndex, pOpenGLTexture->GetTextureID());

			m_TextureList.push_back(Texture);
		}

		return true;
	}
}
#endif USE_OPENGL