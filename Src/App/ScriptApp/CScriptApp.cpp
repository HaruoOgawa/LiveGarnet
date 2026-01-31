#include "CScriptApp.h"

#include <Graphics/CDrawInfo.h>
#include <Graphics/CFrameRenderer.h>
#include <Graphics/PostProcess/CPostProcess.h>
#include <Binary/CBinaryReader.h>

#include <Camera/CCamera.h>
#include <Camera/CTraceCamera.h>
#ifdef USE_VIEWER_CAMERA
#include <Camera/CViewerCamera.h>
#endif // USE_VIEWER_CAMERA

#include <LoadWorker/CLoadWorker.h>
#include <Projection/CProjection.h>
#include <Message/Console.h>
#include <Interface/IGUIEngine.h>
#include <Timeline/CTimelineController.h>
#include <Scene/CSceneController.h>

#include "../../GUIApp/GUI/CGraphicsEditingWindow.h"
#include "../../GUIApp/Model/CFileModifier.h"
#include "../../Live2D/CLive2DEngine.h"

#ifdef USE_NETWORK
#include <Network/CUDPSocket.h>
#endif

namespace app
{
	CScriptApp::CScriptApp() :
		m_SceneController(std::make_shared<scene::CSceneController>()),
		m_MyModelName(std::string()),
		m_Live2DEngine(std::make_shared<livegarnet::CLive2DEngine>()),
		m_CameraSwitchToggle(true),
		m_MainCamera(nullptr),
#ifdef USE_VIEWER_CAMERA
		m_ViewCamera(std::make_shared<camera::CViewerCamera>()),
#else
		m_ViewCamera(std::make_shared<camera::CCamera>()),
#endif // USE_VIEWER_CAMERA
		m_TraceCamera(std::make_shared<camera::CTraceCamera>()),
		m_Projection(std::make_shared<projection::CProjection>()),
		m_DrawInfo(std::make_shared<graphics::CDrawInfo>()),
#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow(std::make_shared<gui::CGraphicsEditingWindow>()),
#endif // USE_GUIENGINE
#ifdef USE_NETWORK
		m_UDPSocket(std::make_shared<network::CUDPSocket>("127.0.0.1", 5000)),
#endif // USE_NETWORK
		m_FileModifier(std::make_shared<CFileModifier>()),
		m_TimelineController(std::make_shared<timeline::CTimelineController>())
	{
		m_ViewCamera->SetPos(glm::vec3(0.0f, -1.0f, 5.45f));
		m_ViewCamera->SetCenter(glm::vec3(0.0f, -1.0f, 4.75f));
		m_MainCamera = m_ViewCamera;

		m_DrawInfo->GetLightCamera()->SetPos(glm::vec3(-2.358f, 15.6f, -0.59f));
		m_DrawInfo->GetLightProjection()->SetNear(2.0f);
		m_DrawInfo->GetLightProjection()->SetFar(100.0f);

		m_SceneController->SetDefaultPass("MainResultPass");

#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow->SetDefaultPass("MainResultPass", "");
#endif
	}

	bool CScriptApp::Release(api::IGraphicsAPI* pGraphicsAPI)
	{
		m_UDPSocket->Close();

		return true;
	}

	bool CScriptApp::Initialize(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		pLoadWorker->AddScene(std::make_shared<resource::CSceneLoader>("Resources\\User\\Scene\\Sample.json", m_SceneController));

		if (!m_UDPSocket->Initialize(shared_from_this(), true)) return false;

		if (!pGraphicsAPI->CreateRenderPass("MainResultPass", api::ERenderPassFormat::COLOR_FLOAT_RENDERPASS, -1, -1)) return false;
		
		m_MainFrameRenderer = std::make_shared<graphics::CFrameRenderer>(pGraphicsAPI, "", pGraphicsAPI->FindOffScreenRenderPass("MainResultPass")->GetFrameTextureList());
		if (!m_MainFrameRenderer->Create(pLoadWorker, "Resources\\Common\\MaterialFrame\\FrameTexture_MF.json")) return false;

		if (!m_Live2DEngine->Initialize()) return false;

		// Live2Dモデルロード
		// ToDo: これらの情報はシーンJSONのuserdataフィールドから取得するようにする(ユーザーがカスタマイズで好きな値を入れることのできるフィールド)
		m_MyModelName = "Hiyori";
		if (!m_Live2DEngine->LoadModel(pGraphicsAPI, m_MyModelName, "Resources/User/Live2D/Hiyori/Hiyori.model3.json", "Idle", 0, "F01")) return false;
		m_Live2DEngine->SetPos(m_MyModelName, glm::vec3(0.0f, -1.25f, 4.75f));

		return true;
	}

	bool CScriptApp::ProcessInput(api::IGraphicsAPI* pGraphicsAPI)
	{
		return true;
	}

	bool CScriptApp::Resize(int Width, int Height)
	{
		m_Projection->SetScreenResolution(Width, Height);

		m_DrawInfo->GetLightProjection()->SetScreenResolution(Width, Height);

		return true;
	}

	bool CScriptApp::Update(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<input::CInputState>& InputState)
	{
		if (!m_FileModifier->Update(pLoadWorker)) return false;

		if (pLoadWorker->IsLoaded())
		{
			if (!m_TimelineController->Update(m_DrawInfo->GetDeltaSecondsTime(), InputState)) return false;
		}

		if (!m_SceneController->Update(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_MainCamera, m_Projection, m_DrawInfo, InputState, m_TimelineController)) return false;

		m_MainCamera->Update(m_DrawInfo->GetDeltaSecondsTime(), InputState);

		if (InputState->IsKeyUp(input::EKeyType::KEY_TYPE_SPACE))
		{
			m_CameraSwitchToggle = !m_CameraSwitchToggle;

			if (m_CameraSwitchToggle)
			{
				m_MainCamera = m_ViewCamera;
			}
			else
			{
				m_MainCamera = m_TraceCamera;
			}
		}

		if (InputState->IsKeyUp(input::EKeyType::KEY_TYPE_1)) m_Live2DEngine->ChangeMotion(m_MyModelName, "TapBody", 0);
		else if (InputState->IsKeyUp(input::EKeyType::KEY_TYPE_2)) m_Live2DEngine->ChangeMotion(m_MyModelName, "TapBody", 1);
		else if (InputState->IsKeyUp(input::EKeyType::KEY_TYPE_3)) m_Live2DEngine->ChangeMotion(m_MyModelName, "TapBody", 2);
		else if (InputState->IsKeyUp(input::EKeyType::KEY_TYPE_4)) m_Live2DEngine->ChangeMotion(m_MyModelName, "TapBody", 3);
		else if (InputState->IsKeyUp(input::EKeyType::KEY_TYPE_5)) m_Live2DEngine->ChangeExpression(m_MyModelName, "F01");
		else if (InputState->IsKeyUp(input::EKeyType::KEY_TYPE_6)) m_Live2DEngine->ChangeExpression(m_MyModelName, "F02");
		else if (InputState->IsKeyUp(input::EKeyType::KEY_TYPE_7)) m_Live2DEngine->ChangeExpression(m_MyModelName, "F03");
		else if (InputState->IsKeyUp(input::EKeyType::KEY_TYPE_8)) m_Live2DEngine->ChangeExpression(m_MyModelName, "F04");
		else if (InputState->IsKeyUp(input::EKeyType::KEY_TYPE_9)) m_Live2DEngine->ChangeExpression(m_MyModelName, "F05");
		else if (InputState->IsKeyUp(input::EKeyType::KEY_TYPE_0)) m_Live2DEngine->ChangeExpression(m_MyModelName, "F06");

		if (!m_MainFrameRenderer->Update(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_MainCamera, m_Projection, m_DrawInfo, InputState)) return false;

		if (!m_Live2DEngine->Update(pGraphicsAPI, m_DrawInfo->GetDeltaSecondsTime())) return false;

		return true;
	}

	bool CScriptApp::LateUpdate(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		if (!m_SceneController->LateUpdate(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_DrawInfo)) return false;

		return true;
	}

	bool CScriptApp::FixedUpdate(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker)
	{
		if (!m_SceneController->FixedUpdate(pGraphicsAPI, pPhysicsEngine, pLoadWorker, m_DrawInfo)) return false;

		return true;
	}

	bool CScriptApp::Draw(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<input::CInputState>& InputState,
		const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		// MainResultPass(フォアグラウンドレンダリング)
		{
			if (!pGraphicsAPI->BeginRender("MainResultPass")) return false;
			if (!m_SceneController->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;
			if (!m_Live2DEngine->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;
			if (!pGraphicsAPI->EndRender()) return false;
		}

		// Main FrameBuffer
		{
			if (!pGraphicsAPI->BeginRender()) return false;

			if (!m_MainFrameRenderer->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;

			// GUIEngine
			std::function<bool(void)> DrawGUIEngine = [this, pLoadWorker, GUIEngine, pGraphicsAPI, pPhysicsEngine, InputState]() {
#ifdef USE_GUIENGINE
				if (pLoadWorker->IsLoaded())
				{
					gui::SGUIParams GUIParams = gui::SGUIParams(shared_from_this(), GetObjectList(), m_SceneController, m_FileModifier, m_TimelineController, pLoadWorker, {}, pPhysicsEngine);
					GUIParams.CameraMode = (m_CameraSwitchToggle) ? "ViewCamera" : "TraceCamera";
					GUIParams.Camera = m_MainCamera;
					GUIParams.InputState = InputState;
					
					if (!GUIEngine->BeginFrame(pGraphicsAPI)) return false;
					if (!m_GraphicsEditingWindow->Draw(pGraphicsAPI, GUIParams, GUIEngine))
					{
						Console::Log("[Error] InValid GUI\n");
						return false;
					}
					if (!GUIEngine->EndFrame(pGraphicsAPI)) return false;
				}
#endif // USE_GUIENGINE

				return true;
			};

			if (!pLoadWorker->Draw(pGraphicsAPI, m_MainCamera, m_Projection, m_DrawInfo)) return false;

			if (!pGraphicsAPI->EndRender(DrawGUIEngine)) return false;
		}

		return true;
	}

	std::shared_ptr<graphics::CDrawInfo> CScriptApp::GetDrawInfo() const
	{
		return m_DrawInfo;
	}

	// 起動準備完了
	bool CScriptApp::OnStartup(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		const auto& TimelineFileName = m_SceneController->GetTimelineFileName();
		if (!TimelineFileName.empty()) pLoadWorker->AddLoadResource(std::make_shared<resource::CTimelineClipLoader>(TimelineFileName, m_TimelineController->GetClip()));

		return true;
	}

	// ロード完了イベント
	bool CScriptApp::OnLoaded(api::IGraphicsAPI* pGraphicsAPI, physics::IPhysicsEngine* pPhysicsEngine, resource::CLoadWorker* pLoadWorker, const std::shared_ptr<gui::IGUIEngine>& GUIEngine)
	{
		if (!m_SceneController->Create(pGraphicsAPI, pPhysicsEngine)) return false;

		if (!m_TimelineController->Initialize(shared_from_this())) return false;

#ifdef USE_GUIENGINE
		{
			gui::SGUIParams GUIParams = gui::SGUIParams(shared_from_this(), GetObjectList(), m_SceneController, m_FileModifier, m_TimelineController, pLoadWorker, {}, pPhysicsEngine);
			
			if (!m_GraphicsEditingWindow->OnLoaded(pGraphicsAPI, GUIParams, GUIEngine)) return false;
		}
#endif

		// カメラ
		{
			const auto& Object = m_SceneController->FindObjectByName("CameraObject");
			if (Object)
			{
				const auto& Node = Object->FindNodeByName("CameraNode");

				if (Node)
				{
					m_TraceCamera->SetTargetNode(Node);
				}
			}
		}

		return true;
	}

	// バイナリ受信イベント
	bool CScriptApp::OnReceiveBinary(const std::vector<unsigned char>& Binary)
	{
		binary::CBinaryReader Analyser(Binary);

		std::string head = std::string();
		if (!Analyser.GetString(head, 4)) return false;

		if (head != "LG2D") return true;

		m_Live2DEngine->OnReceiveData(m_MyModelName, Analyser);

		return true;
	}

	// フォーカスイベント
	void CScriptApp::OnFocus(bool Focused, api::IGraphicsAPI* pGraphicsAPI, resource::CLoadWorker* pLoadWorker)
	{
		if (Focused && pLoadWorker)
		{
			m_FileModifier->OnFileUpdated(pLoadWorker);
		}
	}

	// エラー通知イベント
	void CScriptApp::OnAssertError(const std::string& Message)
	{
#ifdef USE_GUIENGINE
		m_GraphicsEditingWindow->AddLog(gui::EGUILogType::Error, Message);
#endif
	}

	// Getter
	std::vector<std::shared_ptr<object::C3DObject>> CScriptApp::GetObjectList() const
	{
		std::vector<std::shared_ptr<object::C3DObject>> ObjectList;

		for (const auto& Object : m_SceneController->GetObjectList())
		{
			ObjectList.push_back(Object);
		}

		return ObjectList;
	}

	std::shared_ptr<scene::CSceneController> CScriptApp::GetSceneController() const
	{
		return m_SceneController;
	}
}