function y = rosenbrock2(x)
    
    y = (1 - x(:,1)).^2 + 100*(x(:,2) - x(:,1).^2).^2;