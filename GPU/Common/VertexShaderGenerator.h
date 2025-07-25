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

#pragma once

#include <cstdint>

#include "Common/CommonTypes.h"
#include "Common/GPU/Shader.h"
#include "Common/GPU/thin3d.h"

struct VShaderID;

// Can technically be deduced from the vertex shader ID, but this is safer.
enum class VertexShaderFlags : u32 {
	MULTI_VIEW = 1,
};
ENUM_CLASS_BITOPS(VertexShaderFlags);

bool GenerateVertexShader(const VShaderID &id, char *buffer, const ShaderLanguageDesc &compat, const Draw::Bugs bugs, uint32_t *attrMask, uint64_t *uniformMask, VertexShaderFlags *vertexShaderFlags, std::string *errorString);
