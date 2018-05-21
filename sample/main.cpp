/*
 * Copyright (c) 2017 Axel Isouard <axel@isouard.fr>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <api/peerconnectioninterface.h>
#include <api/audio_codecs/builtin_audio_decoder_factory.h>
#include <api/audio_codecs/builtin_audio_encoder_factory.h>
#include <modules/audio_device/include/audio_device.h>
#include <rtc_base/ssladapter.h>
#include <rtc_base/thread.h>

#ifdef WIN32
#include <rtc_base/win32socketinit.h>
#include <rtc_base/win32socketserver.h>
#include <Windows.h>
#endif

int main(int argc, char **argv) {
#ifdef WIN32
  rtc::EnsureWinsockInit();
  rtc::Win32SocketServer w32_ss;
  rtc::Win32Thread w32_thread(&w32_ss);
  rtc::ThreadManager::Instance()->SetCurrentThread(&w32_thread);
#endif

  rtc::InitializeSSL();
  rtc::InitRandom(rtc::Time());
  rtc::ThreadManager::Instance()->WrapCurrentThread();

  rtc::scoped_refptr<webrtc::PeerConnectionFactoryInterface> pcFactory =
      webrtc::CreatePeerConnectionFactory(NULL,
                                          rtc::Thread::Current(),
                                          NULL,
                                          webrtc::AudioDeviceModule::Create(0, webrtc::AudioDeviceModule::kDummyAudio),
                                          webrtc::CreateBuiltinAudioEncoderFactory(),
                                          webrtc::CreateBuiltinAudioDecoderFactory(),
                                          nullptr /* video_encoder_factory */,
                                          nullptr /* video_decoder_factory */);

  pcFactory = NULL;

  rtc::CleanupSSL();
  return 0;
}
