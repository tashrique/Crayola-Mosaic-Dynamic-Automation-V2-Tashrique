from sklearn.cluster import KMeans
import cv2
import sys
import os
import numpy as np

def get_dominant_color(image_path):
    image = cv2.imread(image_path)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image = cv2.resize(image, (40, 40))

    reshaped_image = image.reshape(image.shape[0] * image.shape[1], image.shape[2])

    kmeans = KMeans(n_clusters=1, n_init=2)
    kmeans.fit(reshaped_image)

    return kmeans.cluster_centers_[0]

def get_complementary_color(color):
    # Assuming the color is in RGB format
    comp_color = 255 - np.array(color, dtype=int)
    return comp_color.tolist()

image_path = sys.argv[1]
dominant_color = get_dominant_color(image_path)
dominant_color = [int(a) for a in get_dominant_color(image_path)]
complementary_color = get_complementary_color(dominant_color)
print(','.join(map(str, dominant_color)) + ";" + ','.join(map(str, complementary_color)))
