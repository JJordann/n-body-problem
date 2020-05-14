using LinearAlgebra
using Plots 
using Images

G = 2.95912208286e-4
M = [1.00000597682, 0.000954786104043, 0.000285583733151, 0.0000437273164546, 0.0000517759138449, 1/1.3e8]
N = 6 # number of bodies

planets = ["Sun", "Jupiter", "Saturn", "Uranus", "Neptune", "Pluto"]

pos_x = [0.0,-3.5023653,9.0755314,8.3101420,11.4707666,-15.5387357]
pos_y = [0.0,-3.8169847,-3.0458353,-16.2901086,-25.7294829,-25.2225594]
pos_z = [0.0,-1.5507963,-1.6483708,-7.2521278,-10.8169456,-3.1902382]
pos = [pos_x' ; pos_y' ; pos_z']'

vel_x = [0.0,0.00565429,0.00168318,0.00354178,0.00288930,0.00276725]
vel_y = [0.0,-0.00412490,0.00483525,0.00137102,0.00114527,-0.00170702]
vel_z = [0.0,-0.00190589,0.00192462,0.00055029,0.00039677,-0.00136504]
vel = [vel_x' ; vel_y' ; vel_z']'


#test1 = [-1, 1, 0; 
#         -2, 1, 0; 
#         -1, 2, 0;
#         1, -1, 0;
#         2, -1, 0;
#         1, -2, 0]
#
#vel = 



# image size
n = 512
dt = 50;
iters = 100;

scale = p -> round.(p .* 3 .+ n/2)

#project = p -> [p[1], p[2]] ./ (p[3] + 1)
project = p -> [p[1], p[2]]

function toImage(pos, frame_number)
    img = zeros(3, n, n)

    for i = 1:N
        xy1 = project(pos[i, :]) 
        xy = scale(xy1) .|> (Integer ∘round)

        if (xy[1] >= 1 && xy[1] <= n && xy[2] >= 1 && xy[2] <= n)
            img[:, xy[1], xy[2]] = [1, 1, 1]
        end
    end


    save("frame$(1000 + frame_number).png", colorview(RGB, img))
end

acc = zeros(N, 3)

for iter in 1:iters
    for i in 1:N, j in 1:N
        if i != j
            acc[i, :] += (G * M[j] ./ norm(pos[j, :] - pos[i, :]) ^ 3) .* (pos[j, :] - pos[i, :])
        end
    end
    global vel = vel .+ (acc .* dt)
    global pos = pos .+ (vel .* dt)
    global acc = zeros(N, 3)
    #scatter3d(pos[:, 1], pos[:, 2], pos[:, 3])
    toImage(pos, iter);
end





