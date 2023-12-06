
in vec2 mcPosition;     // The is position of a vertex of quad
in vec2 mcTexCoords;    // texcoords of the vertex

smooth out vec4 color;

void main(void)
{
    color = vec4(mcTexCoords.xy, 0, 1.0);
    gl_Position = vec4(mcPosition, 0.0, 1.0);
}
