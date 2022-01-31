import pandas as pd
from sklearn.svm import SVC
from sklearn.metrics import classification_report, f1_score, confusion_matrix
from sklearn.model_selection import train_test_split
import sys

from warnings import filterwarnings
filterwarnings('ignore')

data_path = str(sys.argv[1])
data = pd.read_csv(data_path)

cor = data.corr()
threshold = 0.2
target_corr = abs(cor["target"])
features_list = list(target_corr[target_corr>threshold].index)
features_list.remove('target')

X, y = data.loc[:, features_list], data['target']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

model = SVC(kernel = 'linear', C=30, max_iter=2000)
model.fit(X_train, y_train)

y_pred = model.predict(X_test)
print("Model Trained!")
print(classification_report(y_test, y_pred))
