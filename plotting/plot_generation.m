function plot_generation(gen, game, prisoners, most_fit)
    hold on
    marker_size = 16;
        
    beta = setdiff(1:game.num_prisoners, most_fit);
    alpha = most_fit;
    beta = prisoners(beta);
    alpha = prisoners(alpha);
    
    coops = zeros(size(beta));
    for i = 1:length(coops)
        coops(i) = beta{i}.Cooperation;
    end    
    plot(gen .* ones(1, length(beta)), coops, '.b', 'MarkerSize', marker_size)
    
    coops = zeros(size(alpha));
    for i = 1:length(coops)
        coops(i) = alpha{i}.Cooperation;
    end
    plot(gen .* ones(1, length(alpha)), coops, '.r', 'MarkerSize', marker_size)
    
    title('Cooperation', 'FontSize', 18)
    xlabel('Generation')
    ylabel('% Cooperation')
    xlim([0 game.num_generations + 1])
    xticks(1:game.num_generations)
    ylim([0 1])
end