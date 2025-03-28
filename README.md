# Experiment on Amharic Sign Language Classification Using ResNet50 and CNN
Objective

The goal of this experiment was to develop an Amharic Sign Language classifier by leveraging deep learning techniques. The approach involved using ResNet50 as a feature extractor and a Convolutional Neural Network (CNN) for training the classifier. The model was trained on a dataset consisting of 1,750 images, representing 10 different sign classes.
Methodology

    Feature Extraction: ResNet50, a pre-trained deep convolutional neural network, was employed to extract meaningful image features. This step aimed to leverage its powerful feature representation capabilities while reducing the complexity of training a custom model from scratch.

    Model Training: A CNN-based classifier was trained using the extracted features. The dataset included 1,750 images distributed across 10 sign classes. The model was trained using standard deep learning techniques, including data augmentation and optimization strategies, to improve performance.

    Evaluation: The model was evaluated using accuracy metrics on both training and test datasets.

Results and Observations

During training, the classifier achieved an impressively high accuracy of approximately 98%. However, real-world testing revealed a significant drop in performance. The primary issue was overfitting—instead of learning generalizable patterns, the model memorized specific image features. This occurred due to the lack of image variability, meaning that despite having 1,750 images, their similarity prevented the model from learning diverse representations. Consequently, when tested on new, unseen images, the model failed to classify them accurately.
Conclusion

The experiment ultimately failed due to overfitting. While the model performed exceptionally well on the training set, it struggled with real-world variations. To improve generalization, future iterations should focus on:

    Increasing dataset diversity through varied lighting conditions, angles, and hand positions.

    Applying stronger data augmentation techniques to simulate real-world variations.

    Exploring different architectures or fine-tuning the feature extractor to enhance generalization.
