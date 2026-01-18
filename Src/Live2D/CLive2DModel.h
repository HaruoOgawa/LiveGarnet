#pragma once

#include <memory>
#include <string>

#include <ICubismModelSetting.hpp>
#include <Model/CubismUserModel.hpp>

namespace livegarnet
{
	class CLive2DModel
	{
		// ƒ‚ƒfƒ‹İ’è
		std::shared_ptr<Csm::ICubismModelSetting> m_ModelSetting;

		// ƒ‚ƒfƒ‹–{‘Ì
		std::shared_ptr<Csm::CubismUserModel> m_UserModel;

	private:
		bool LoadMoc3(const std::string& Directory);

	public:
		CLive2DModel();
		virtual ~CLive2DModel();

		bool Load(const std::string& model3Path);
		bool Update();
		bool Draw();
	};
}