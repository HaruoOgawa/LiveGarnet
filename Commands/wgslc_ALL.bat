@rem common shaders ///////////////////////////////////////////////////////////////////
set CurrentDir=%~dp0
set ShaderDir=..\Resources\Common\Shaders

for /R %ShaderDir% %%i in (*.vert) do glslc.exe -o %%~pi%%~ni_vert.spv %%~i

for /R %ShaderDir% %%i in (*.frag) do glslc.exe -o %%~pi%%~ni_frag.spv %%~i

for /R %ShaderDir% %%i in (*.comp) do glslc.exe -o %%~pi%%~ni_comp.spv %%~i

for /R %ShaderDir% %%i in (*.spv) do naga %%~i %%~pi%%~ni.wgsl 

@rem user shaders ///////////////////////////////////////////////////////////////////
set CurrentDir=%~dp0
set ShaderDir=..\Resources\User\Shaders

for /R %ShaderDir% %%i in (*.vert) do glslc.exe -o %%~pi%%~ni_vert.spv %%~i

for /R %ShaderDir% %%i in (*.frag) do glslc.exe -o %%~pi%%~ni_frag.spv %%~i

for /R %ShaderDir% %%i in (*.comp) do glslc.exe -o %%~pi%%~ni_comp.spv %%~i

for /R %ShaderDir% %%i in (*.spv) do naga %%~i %%~pi%%~ni.wgsl 

pause