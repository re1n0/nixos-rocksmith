{
  lib,
  stdenv,
  fetchFromGitHub,
  llvmPackages,
  pkgsi686Linux,
  cacert,
}: let
  target = "i686-pc-windows-msvc";
  sdk = pkgsi686Linux.windows.sdk.overrideAttrs (oldAttrs: {
    src = oldAttrs.src.overrideAttrs (_: {
      SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
      NIX_SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    });
  });
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "rs-asio";

    version = "0.7.5";

    src = fetchFromGitHub {
      owner = "mdias";
      repo = "rs_asio";
      rev = "v0.7.5";
      hash = "sha256-SUdftM7HFPHZgL2CbjGe62ppuhSneYT0GQ0VqoO4YDs=";
    };

    nativeBuildInputs = [
      llvmPackages.clang-unwrapped
      llvmPackages.lld
      llvmPackages.llvm
    ];

    hardeningDisable = ["all"];

    dontConfigure = true;
    dontFixup = true;
    dontStrip = true;

    postPatch = ''
      substituteInPlace avrt/dllmain.cpp \
        --replace-fail "RealFunctions.##x" "RealFunctions.x"

      substituteInPlace avrt/targetver.h \
        --replace-fail "SDKDDKVer.h" "sdkddkver.h"

      substituteInPlace RS_ASIO/targetver.h \
        --replace-fail "SDKDDKVer.h" "sdkddkver.h"

      substituteInPlace RS_ASIO/NtProtectVirtualMemory.asm \
          --replace-fail "NtProtectVirtualMemory PROC" "_NtProtectVirtualMemory PROC" \
          --replace-fail "NtProtectVirtualMemory ENDP" "_NtProtectVirtualMemory ENDP"

      substituteInPlace RS_ASIO/MyUnknown.h \
        --replace-fail \
          "DEFINE_GUID(IID_IMyUnknown , 0xf2d67f48, 0x1977, 0x4991, 0xa3, 0xfc, 0xa0, 0x93, 0x83, 0x5a, 0x7d, 0xc2);" \
          "EXTERN_C const GUID DECLSPEC_SELECTANY IID_IMyUnknown = { 0xf2d67f48, 0x1977, 0x4991, { 0xa3, 0xfc, 0xa0, 0x93, 0x83, 0x5a, 0x7d, 0xc2 } };"
    '';

    buildPhase = ''
      runHook preBuild

      pushd avrt

      clang-cl \
        --target=${target} \
        /vctoolsdir ${sdk}/crt \
        /winsdkdir ${sdk}/sdk \
        /MT /EHsc /W3 /nologo /c \
        /DWIN32 /DNDEBUG /DAVRT_EXPORTS /D_WINDOWS /D_USRDLL /DUNICODE /D_UNICODE \
        avrt.cpp dllmain.cpp stdafx.cpp

      clang-cl \
        --target=${target} \
        /vctoolsdir ${sdk}/crt \
        /winsdkdir ${sdk}/sdk \
        -fuse-ld=lld \
        avrt.obj dllmain.obj stdafx.obj \
        /link /DLL /DEF:avrt.def /OUT:avrt.dll /SUBSYSTEM:WINDOWS \
        kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib \
        advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib \
        odbc32.lib odbccp32.lib

      popd

      pushd RS_ASIO

      llvm-ml \
        -m32 \
        -c NtProtectVirtualMemory.asm \
        -Fo NtProtectVirtualMemory.obj

      clang-cl \
        --target=${target} \
        /vctoolsdir ${sdk}/crt \
        /winsdkdir ${sdk}/sdk \
        /MT /EHsc /W3 /nologo /std:c++17 /c \
        /DWIN32 /DNDEBUG /DRSASIO_EXPORTS /D_WINDOWS /D_USRDLL /D_CRT_SECURE_NO_WARNINGS /DUNICODE /D_UNICODE \
        AsioHelpers.cpp AsioSharedHost.cpp AudioProcessing.cpp crc32.cpp \
        DebugWrapperAudioClient.cpp DebugWrapperAudioEndpointVolume.cpp \
        DebugWrapperCaptureClient.cpp DebugWrapperDevice.cpp \
        DebugWrapperDevicePropertyStore.cpp DebugWrapperEndpoint.cpp \
        DebugWrapperRenderClient.cpp dllmain.cpp Log.cpp Patcher.cpp \
        Patcher_6ea6d1ba.cpp Patcher_d1b38fcb.cpp Patcher_21a8959a.cpp \
        RSAsioAudioCaptureClient.cpp RSAsioAudioClient.cpp \
        RSAsioAudioClientServiceBase.cpp RSAsioAudioEndpointVolume.cpp \
        RSAsioAudioRenderClient.cpp RSAsioDevice.cpp RSAsioDeviceEnum.cpp \
        RSAsioDevicePropertyStore.cpp RSBaseDeviceEnum.cpp RSDeviceCollection.cpp \
        Configurator.cpp RSAggregatorDeviceEnum.cpp stdafx.cpp \
        DebugDeviceEnum.cpp Utils.cpp

      clang-cl \
        --target=${target} \
        /vctoolsdir ${sdk}/crt \
        /winsdkdir ${sdk}/sdk \
        -fuse-ld=lld \
        *.obj \
        /link /DLL /DEF:exports.def /OUT:RS_ASIO.dll /SUBSYSTEM:WINDOWS \
        /SAFESEH:NO \
        kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib \
        advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib \
        odbc32.lib odbccp32.lib winmm.lib

      popd

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/lib"
      cp avrt/avrt.dll "$out/lib/"
      cp RS_ASIO/RS_ASIO.dll "$out/lib/"

      runHook postInstall
    '';

    meta = {
      homepage = "https://github.com/mdias/rs_asio";
      changelog = "https://github.com/mdias/rs_asio/releases/tag/v${finalAttrs.version}";
      description = "ASIO for Rocksmith 2014";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [
        rein
      ];
    };
  })
