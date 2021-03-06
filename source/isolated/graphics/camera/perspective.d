﻿module isolated.graphics.camera.perspective;

public import isolated.graphics.camera.camera;
import isolated.math;

class PerspectiveCamera : Camera
{
	private {
		const float FOV = 70;
	}

	this(vec2i viewport) {
		this(viewport, vec3(0, 0, 0));
	}

	this(vec2i viewport, vec3 position) {
		super(viewport, position);
	}

	override void calculate() {
		if(_dirty) {
			projectionMatrix = mat4.perspective(viewport.x, viewport.y, FOV, abs(NEAR_PLANE), abs(FAR_PLANE));

			viewMatrix.make_identity();
			viewMatrix.translate(-translation);
			viewMatrix.rotatey(-(yaw - PI_2)); // Because it is needed that at the start, the camera points toward negative z
			viewMatrix.rotatex(-pitch);

			_dirty = false;
		}
	}
}
