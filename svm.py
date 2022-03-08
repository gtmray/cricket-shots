import numpy as np

class SVM:
    def __init__(self, learning_rate=0.001, lambda_p=0.01, epochs=1000):
        self.lr = learning_rate
        self.lambda_p = lambda_p
        self.epochs = epochs
        self.w = None
        self.b = None

    def fit(self, X, y):
        samples_size, features_size = X.shape

        y_ = np.where(y <= 0, -1, 1) # Since 1 and -1 are two classes. If 0 or less, make it -1

        self.w = np.zeros(features_size)
        self.b = 0

        for i in range(self.epochs):
            for idx, x_i in enumerate(X):
                cond_gt_one = y_[idx] * (np.dot(x_i, self.w) - self.b) >= 1
                if cond_gt_one:
                    self.w -= self.lr * (2 * self.lambda_p * self.w)
                else:
                    self.w -= self.lr * (
                        2 * self.lambda_p * self.w - np.dot(x_i, y_[idx])
                    )
                    self.b -= self.lr * y_[idx]
                    
            if i % 100 == 0: # Print hinge loss every 100 epochs
                cost = self.lambda_p * np.linalg.norm(self.w)**2 + 1 / samples_size * \
                    np.max(np.c_[np.zeros(samples_size), 1 - y_ * (np.dot(X, self.w) - self.b)])  # hinge loss function
                print(f"Iteration {i:<10} Loss: {cost}")

    def predict(self, X):
        approx = np.dot(X, self.w) - self.b
        return np.sign(approx) # Since 1 and -1 are the two classes