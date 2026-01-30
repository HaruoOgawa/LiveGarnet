#pragma once

#include <map>
#include <string>
#include <Model/CubismModel.hpp>

using namespace Csm;

namespace livegarnet
{
	struct SLive2DBone
	{
		bool Updated = false; // このフラグがtrueになっていなければスケルトンによる値上書きは実行しない
		float Value = 0.0f;
		float Min = FLT_MIN;
		float Max = FLT_MAX;

	public:
		SLive2DBone() {}
		SLive2DBone(float _Min, float _Value, float _Max):
			Updated(false), Min(_Min), Value(_Value), Max(_Max) { }
	};

	class CLive2DSkeleton
	{
		std::map<std::string, SLive2DBone> m_CommonBoneMap;

	private:
		void CreateCommonBoneList();

	public:
		CLive2DSkeleton();
		virtual ~CLive2DSkeleton();

		void Create();
		
		bool SetCommonBoneValue(const std::string& BoneName, float Value, float Rate);

		bool Update(CubismModel* _model);
	};
}