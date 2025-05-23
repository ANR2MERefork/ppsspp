// Copyright (c) 2012- PPSSPP Project.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 2.0 or later versions.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License 2.0 for more details.

// A copy of the GPL 2.0 should have been included with the program.
// If not, see http://www.gnu.org/licenses/

// Official git repository and contact information can be found at
// https://github.com/hrydgard/ppsspp and http://www.ppsspp.org/.


// NOTE: This is now unmaintained legacy code. scePsmf/scePsmfPlayer is just a wrapper over sceMpeg
// which is always shipped by games that use it, so we simply load the libraries now and focus
// on emulating sceMpeg as accurately as possible. We might actually go one step deeper if we can
// figure out sceVideocodec, as sceMpeg is also often shipped (but not always!)

#pragma once

void Register_scePsmf();
void Register_scePsmfPlayer();

void __PsmfInit();
void __PsmfPlayerLoadModule(int devkitVersion, u32 crc);
void __PsmfDoState(PointerWrap &p);
void __PsmfPlayerDoState(PointerWrap &p);
void __PsmfShutdown();
