function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

% 构建y矩阵
y_matrix = zeros(m, num_labels);
for i=1:m
	y_matrix(i, y(i)) = 1;
end
%fprintf("y_matrix size = (%d, %d) \n", size(y_matrix));

%假设
h1 = sigmoid([ones(m, 1) X] * Theta1');
h2 = sigmoid([ones(m, 1) h1] * Theta2');

% 迭代
%for i=1:m
%	sumk = 0;
%	for j=1:num_labels
%			sumk=sumk + (-y_matrix(i, j))*log(h2(i, j)) - (1 - y_matrix(i, j))*log(1-h2(i,j));
%		end
%	J = J + sumk;
%	end
%J = J/m;

% 循环+矩阵
%res = zeros(m,1);
%for i=1:m
%	res(i) = -y_matrix(i,:)*log(h2(i,:)') - (1-y_matrix(i,:))*log(1-h2(i,:)'); 
%end

%J = sum(res)/m;

% 纯矩阵
j_matrix = -y_matrix*log(h2') - (1-y_matrix)*log(1-h2'); % 得到一个m*m的矩阵，对角线上的值是我们需要的

% j_matrix.*eye(m) 保留对角线上的值
% sum(sum(j_matrix.*eye(m))) 只对对角线上的值求和
J = sum(sum(j_matrix.*eye(m)))/m;



%正则化
regular = lambda/2/m*(sum(sum(Theta1(:, 2: size(Theta1, 2)).^2, 2)) + sum(sum(Theta2(:, 2: size(Theta2, 2)).^2, 2)));

J = J + regular;

%反向传播

% 循环
for i=1:m
	a1 = [1, X(i, :)]; %size=(1, 401),特么，这里一开始把i写成了m，查了好久才发现...欲哭无泪

	%z2 = [1, a1 * Theta1']; %size=(1, 26)
	z2 = a1 * Theta1'; %size=(1, 25)
	a2 = [1, sigmoid(z2)]; %size=(1, 26)

	z3 = a2 * Theta2'; %size=(1, 10)
	a3 = sigmoid(z3); %size=(1, 10)
	%fprintf("a3 = [%f, %f, %f, %f, %f, %f, %f, %f, %f, %f]\n", a3);
	%fprintf("a3-h2 = [%f, %f, %f, %f, %f, %f, %f, %f, %f, %f]\n", a3-h2(i, :));

	%fprintf("y_matrix size = (%d, %d) \n", size(y_matrix));

	%error3 = a3 - [y_matrix(i, num_labels), y_matrix(i, 1:(num_labels-1))]; % size=(1, 10);
	error3 = a3 - y_matrix(i, :); % size=(1, 10);
	%fprintf("y_matrix = [%d, %d, %d, %d, %d, %d, %d, %d, %d, %d]\n", y_matrix(i, :));
	%fprintf("error3 = [%f, %f, %f, %f, %f, %f, %f, %f, %f, %f]\n", error3);

	%error2 = Theta2'*error3'.*sigmoidGradient([1, z2]'); % size=(26, 1)

	error2 = Theta2'*error3'.*a2'.*(1-a2'); % size=(26, 1)


	Theta1_grad = Theta1_grad + error2(2:end)*a1; %(25, 401)
	Theta2_grad = Theta2_grad + error3'*a2; %(10, 26)

end

Theta1_grad(:, 1) = 1/m*Theta1_grad(:, 1);
%fprintf("Theta1_grad size = (%d, %d) \n", size(Theta1_grad));

Theta2_grad(:, 1) = 1/m*Theta2_grad(:, 1);
%fprintf("Theta2_grad size = (%d, %d) \n", size(Theta2_grad));

% 正则化
Theta1_grad(:, 2:end) = 1/m*Theta1_grad(:, 2:end) + lambda/m*Theta1(:, 2:end);

Theta2_grad(:, 2:end) = 1/m*Theta2_grad(:, 2:end) + lambda/m*Theta2(:, 2:end);


% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
