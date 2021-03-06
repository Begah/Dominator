﻿module isolated.graphics.vertexattribute;

import std.conv;

import isolated.graphics.utils.opengl;

class VertexAttribute
{
	static enum Usage {
		Position = 1,
		ColorUnpacked = 2,
		ColorPacked = 4,
		Normal = 8,
		TextureCoordinates = 16,
		Generic = 32,
		BoneWeight = 64,
		Tangent = 128,
		BiNormal = 256
	}

	size_t vertexSize;
	float[] data;
	Usage usage;
	size_t vaoIndex; // Index in vao set when mesh is generated

	GLuint vbo;

	bool isDynamic = false;

	private bool isDirty;
	private size_t indexStart, indexEnd;

@trusted nothrow :

	this(VertexAttribute other) {
		this.vertexSize = other.vertexSize;
		this.data = other.data.dup;
		this.usage = other.usage;
		this.vaoIndex = other.vaoIndex;
		this.isDynamic = other.isDynamic;
	}

	this(Usage usage, size_t vertexSize) {
		this.usage = usage;
		this.vertexSize = vertexSize;
	}

	static VertexAttribute Position() {
		return new VertexAttribute(Usage.Position, 3);
	}

	static VertexAttribute TexCoords() {
		return new VertexAttribute(Usage.TextureCoordinates, 2);
	}

	static VertexAttribute Normal() {
		return new VertexAttribute(Usage.Normal, 3);
	}

	static VertexAttribute ColorPacked () {
		return new VertexAttribute(Usage.ColorPacked, 4);
	}

	static VertexAttribute ColorUnpacked () {
		return new VertexAttribute(Usage.ColorUnpacked, 4);
	}

	static VertexAttribute Tangent () {
		return new VertexAttribute(Usage.Tangent, 3);
	}

	static VertexAttribute Binormal () {
		return new VertexAttribute(Usage.BiNormal, 3);
	}

	static VertexAttribute BoneWeight (int unit) {
		return new VertexAttribute(Usage.BoneWeight, 2);
	}


	VertexAttribute add(float[] data...) in { assert(data.length % vertexSize == 0, "Adding data to vertex attribute needs to be divisible by " ~ to!string(vertexSize)); }
	body {
		this.data ~= data;

		return this;
	}

	VertexAttribute set(float[] data) in { assert(data.length % vertexSize == 0, "Adding data to vertex attribute needs to be divisible by " ~ to!string(vertexSize)); }
	body {
		this.data = data;

		return this;
	}

	VertexAttribute replace(size_t start, size_t end, float[] data...) in { assert(data.length % vertexSize == 0, "Replacing data to vertex attribute needs to be divisible by " ~ to!string(vertexSize)); }
	body {
		this.data[start * vertexSize .. start * vertexSize + data.length] = data;
		if(indexStart > start) indexStart = start;
		if(indexEnd < end) indexEnd = end;
		isDirty = true;

		return this;
	}

	@property vertexCount() {
		return data.length / vertexSize;
	}

	VertexAttribute toggleDynamic() @property { 
		isDynamic = !isDynamic; 
		return this;
	}

	VertexAttribute generate() {
		if(vbo != GLuint.init && !this.isDynamic) {
			glDeleteBuffers(1, &vbo);
		} else if(vbo != GLuint.init && this.isDynamic) {
			glBufferData(GL_ARRAY_BUFFER, data.length * float.sizeof, data.ptr, GL_DYNAMIC_DRAW);
		} else {
			glGenBuffers(1, &vbo);
			glBindBuffer(GL_ARRAY_BUFFER, vbo);
			glBufferData(GL_ARRAY_BUFFER, data.length * float.sizeof, data.ptr, this.isDynamic ? GL_DYNAMIC_DRAW : GL_STATIC_DRAW);
		}

		isDirty = false;

		return this;
	}

	void refresh() {
		if(isDirty && isDynamic) {
			glBindBuffer(GL_ARRAY_BUFFER, vbo);
			glBufferSubData(GL_ARRAY_BUFFER, indexStart * vertexSize * float.sizeof,(indexEnd - indexStart) * vertexSize * float.sizeof, data.ptr + (indexStart * vertexSize * float.sizeof));
			isDirty = false;
		}
	}

	~this() {
		if(vbo != GLuint.init) {
			glDeleteBuffers(1, &vbo);
		}
		data = null;
	}
}
