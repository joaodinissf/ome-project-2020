function game = create_game(cc, cd_w, cd_l, dd, num_iters)
    if nargin ~= 4
        cc = 2;
        cd_w = 3;
        cd_l = -1;
        dd = 0;
        num_iters = 100;
    end

    game.cc = cc;
    game.cd_w = cd_w;
    game.cd_l = cd_l;
    game.dd = dd;
    
    game.num_iters = num_iters;
end
