precision mediump float;
uniform float time;
uniform vec2  mouse;
uniform vec2  resolution;

const float sphereSize = 1.0;
const float PI    = 3.14159265359;
const float DEG_TO_RAD = PI / 180.0;
const float angle = 60.0;
const float fov   = angle * 0.5 * DEG_TO_RAD;
const vec3  lightPos = vec3(-0.5777, 0.5777, 0.5777);

float smoothMin(float d1, float d2, float k) {
    float h = exp(-k * d1) + exp(-k * d2);
    return -log(h) / k;
}

float distanceFuncSphere(vec3 rayPosition, vec3 position) {
    vec3 delta = position - rayPosition;
    return length(delta) - sphereSize;
}

float distanceFuncBox(vec3 rayPosition, vec3 position) {
    vec3 q = abs(position - rayPosition);
    return length(max(q - vec3(1.5, 0.2, 0.5), 0.0)) - 0.1;
}

float distanceFunc(vec3 rayPosition, vec3 boxPos, vec3 spherePos) {
    float d1 = distanceFuncBox(rayPosition, boxPos);
    float d2 = distanceFuncSphere(rayPosition, spherePos);
    return smoothMin(d1, d2, 8.0);
    /*return min(d1, d2);*/
}

vec3 getNormal(vec3 rayPosition, vec3 position) {
    // 差分
    const float d = 0.0001;
    return normalize(vec3(
        distanceFuncBox(rayPosition + vec3(  d, 0.0, 0.0), position) - distanceFuncBox(rayPosition + vec3( -d, 0.0, 0.0), position),
        distanceFuncBox(rayPosition + vec3(0.0,   d, 0.0), position) - distanceFuncBox(rayPosition + vec3(0.0,  -d, 0.0), position),
        distanceFuncBox(rayPosition + vec3(0.0, 0.0,   d), position) - distanceFuncBox(rayPosition + vec3(0.0, 0.0,  -d), position)
    ));
}

void main() {
    vec2 p = (gl_FragCoord.xy * 2.0 - resolution) / min(resolution.x, resolution.y);

    // Camera
    vec3 cameraPos  = vec3(-5.0, 3.0, 5.0);
    vec3 cameraDir  = vec3(0.577, -0.577, -0.577);
    vec3 cameraUp   = vec3(0.577, 0.577, -0.577);
    vec3 cameraSide = cross(cameraDir, cameraUp);
    /*vec3 cPos = vec3(mouse.xy, 2.0);*/
    float targetDepth = 1.0;

    // Ray
    // vec3 ray = normalize(vec3(sin(fov) * p.x, sin(fov) * p.y, -cos(fov)));
    vec3 ray = normalize(cameraSide * p.x + cameraUp * p.y + cameraDir * targetDepth);

    // Marching loop
    float distance = 0.0;
    float rLen = 0.0;
    vec3  rPos = cameraPos;

    vec3 spherePos = vec3(0.0, -(mouse.y * 2.0 - 1.0) * 5.0, (mouse.x * 2.0 - 1.0) * 5.0);
    /*vec3 boxPos = vec3(mouse.x, -mouse.y, -5.0);*/
    vec3 boxPos = vec3(0.0, 0.0, 0.0);

    for (int i = 0; i < 64; i++) {
        distance = distanceFunc(rPos, boxPos, spherePos);
        rLen += distance;
        rPos = cameraPos + ray * rLen;
    }

    if (abs(distance) < 0.001) {
        /*float diffuse = clamp(dot(getNormal(rPos, spherePos), lightPos), 0.1, 1.0);*/
        float diffuse = clamp(dot(getNormal(rPos, boxPos), lightPos), 0.1, 1.0);
        gl_FragColor = vec4(vec3(1.0), 1.0) * vec4(vec3(diffuse), 1.0);
    }
    else {
        gl_FragColor = vec4(vec3(0.0), 1.0);
    }
}
