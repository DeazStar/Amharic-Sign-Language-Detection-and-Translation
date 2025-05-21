from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv1D, MaxPooling1D, Dropout, GlobalAveragePooling1D, Dense, BatchNormalization, Activation
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping

class CNN:
    def __init__(self, input_shape, num_classes):
        self.input_shape = input_shape
        self.num_classes = num_classes

    def build_model(self):
        model = Sequential([
            Conv1D(64, kernel_size=5, padding='same'),
            BatchNormalization(),
            Activation('relu'),
            MaxPooling1D(pool_size=2),
            Dropout(0.2),

            Conv1D(64, kernel_size=3, padding='same'),
            BatchNormalization(),
            Activation('relu'),
            GlobalAveragePooling1D(),

            Dense(32),
            BatchNormalization(),
            Activation('relu'),
            Dropout(0.3),

            Dense(self.num_classes, activation='softmax')
        ])
        model.compile(optimizer=Adam(learning_rate=0.0005),
                      loss='categorical_crossentropy',
                      metrics=['accuracy'])
        return model

