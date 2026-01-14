#ifdef USE_GUIENGINE
#include "CGUIBaseTab.h"
#include "../../Object/C3DObject.h"

namespace gui
{
	bool CGUIBaseTab::Draw(const std::vector<std::shared_ptr<object::C3DObject>>& ObjectList, int SelectedObjectIndex, int SelectedNodeIndex)
	{
		if (ImGui::BeginTabItem("Base"))
		{
			if (SelectedObjectIndex >= 0 && SelectedObjectIndex < static_cast<int>(ObjectList.size()))
			{
				const auto& Object = ObjectList[SelectedObjectIndex];

				// 後回し
				/*// PassName
				{
					std::string PassName = Object->GetPassName();

					char buf[256] = "";
					std::memcpy(&buf[0], &PassName[0], PassName.size());
					
					if (ImGui::InputText("PassName##CGUIBaseTab::Draw", buf, IM_ARRAYSIZE(buf)))
					{
						PassName = std::string(buf);

						Object->SetPassName(PassName);
					}
				}*/

				const auto& NodeList = Object->GetNodeList();
				const auto& MeshList = Object->GetMeshList();

				if (SelectedNodeIndex >= 0 && SelectedNodeIndex < static_cast<int>(NodeList.size()))
				{
					//ImGui::SeparatorText("Node Transform");

					const auto& Node = NodeList[SelectedNodeIndex];

					// メッシュ
					int MeshIndex = Node->GetMeshIndex();
					if (ImGui::InputInt("MeshIndex##CGUIBaseTab", &MeshIndex))
					{
						if (MeshIndex >= 0 && MeshIndex < static_cast<int>(MeshList.size()))
						{
							Node->SetMeshIndex(MeshIndex);
						}
					}

					// Node Transformを表示
					const auto& Transform = Node->GetLocalTransform();

					if (!DrawTransformGUI(Transform)) return false;

					// コンポーネントリスト
					ImGui::SeparatorText("ComponentList");

					for (const auto& Component : Node->GetComponentList())
					{
						if (!DrawComponentGUI(Component)) return false;
					}
				}
				else
				{
					//ImGui::SeparatorText("Object Transform");

					// Object Transformを表示
					const auto& Transform = Object->GetObjectTransform();

					if (!DrawTransformGUI(Transform)) return false;
				}
			}

			ImGui::EndTabItem();
		}

		return true;
	}

	bool CGUIBaseTab::DrawTransformGUI(const std::shared_ptr<math::CTransform>& Transform)
	{
		// Pos
		glm::vec3 Pos = Transform->GetPos();

		if(ImGui::InputFloat3("Position", &Pos[0]))
		{
			Transform->SetPos(Pos);
		}

		// Rotate
		glm::quat Rot = Transform->GetRot();
		glm::vec3 Euler = glm::eulerAngles(Rot);
		glm::vec3 Degree = glm::vec3(glm::degrees(Euler.x), glm::degrees(Euler.y), glm::degrees(Euler.z));
		const glm::vec3 PreDegree = Degree;

		if (ImGui::InputFloat3("Rotation", &Degree[0]))
		{
			if (PreDegree.x != Degree.x || PreDegree.y != Degree.y || PreDegree.z != Degree.z)
			{
				Rot = glm::angleAxis(glm::radians(Degree.z), glm::vec3(0.0f, 0.0f, 1.0f)) * glm::angleAxis(glm::radians(Degree.y), glm::vec3(0.0f, 1.0f, 0.0f)) * glm::angleAxis(glm::radians(Degree.x), glm::vec3(1.0f, 0.0f, 0.0f));
			}
			
			Transform->SetRot(Rot);
		}

		// Scale
		glm::vec3 Scale = Transform->GetScale();

		if (ImGui::InputFloat3("Scale", &Scale[0]))
		{
			Transform->SetScale(Scale);
		}

		return true;
	}

	bool CGUIBaseTab::DrawComponentGUI(const std::shared_ptr<scriptable::CComponent>& Component)
	{
		const auto& ValueRegistry = Component->GetValueRegistry();
		if (!ValueRegistry) return true;

		for (const auto& Value : ValueRegistry->GetValueList())
		{
			const std::string& Name = Value.second.Name;
			graphics::EUniformValueType Type = Value.second.Type;
			int ByteSize = Value.second.ByteSize;
			const auto& Buffer = Value.second.Buffer;

			switch (Type)
			{
			case graphics::EUniformValueType::NONE:
				continue;
			case graphics::EUniformValueType::VALUE_TYPE_MAT4:
				continue;
			case graphics::EUniformValueType::VALUE_TYPE_MAT3:
				continue;
			case graphics::EUniformValueType::VALUE_TYPE_MAT2:
				continue;
			case graphics::EUniformValueType::VALUE_TYPE_VEC4:
			{
				glm::vec4 val = glm::vec4(0.0f);
				std::memcpy(&val[0], &Buffer[0], ByteSize);

				if (ImGui::InputFloat4(Name.c_str(), &val[0]))
				{
					ValueRegistry->SetValue(Name, Type, &val[0], ByteSize);
				}
			}
			break;
			case graphics::EUniformValueType::VALUE_TYPE_VEC3:
			{
				glm::vec3 val = glm::vec3(0.0f);
				std::memcpy(&val[0], &Buffer[0], ByteSize);

				if (ImGui::InputFloat3(Name.c_str(), &val[0]))
				{
					ValueRegistry->SetValue(Name, Type, &val[0], ByteSize);
				}
			}
			break;
			case graphics::EUniformValueType::VALUE_TYPE_VEC2:
			{
				glm::vec2 val = glm::vec2(0.0f);
				std::memcpy(&val[0], &Buffer[0], ByteSize);

				if (ImGui::InputFloat2(Name.c_str(), &val[0]))
				{
					ValueRegistry->SetValue(Name, Type, &val[0], ByteSize);
				}
			}
			break;
			case graphics::EUniformValueType::VALUE_TYPE_FLOAT:
			{
				glm::vec1 val = glm::vec1(0.0f);
				std::memcpy(&val[0], &Buffer[0], ByteSize);

				if (ImGui::InputFloat(Name.c_str(), &val[0]))
				{
					ValueRegistry->SetValue(Name, Type, &val[0], ByteSize);
				}
			}
			break;
			case graphics::EUniformValueType::VALUE_TYPE_INT:
			{
				glm::ivec1 val = glm::ivec1(0);
				std::memcpy(&val[0], &Buffer[0], ByteSize);

				if (ImGui::InputInt(Name.c_str(), &val[0]))
				{
					ValueRegistry->SetValue(Name, Type, &val[0], ByteSize);
				}
			}
			break;
			case graphics::EUniformValueType::VALUE_TYPE_FLOAT_ARRAY:
				continue;
			case graphics::EUniformValueType::VALUE_TYPE_MAT4_ARRAY:
				continue;
			default:
				break;
			}
		}

		return true;
	}
}
#endif