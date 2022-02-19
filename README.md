# ReproducibilityPackage

This is the reproduction package for the portfolio exam in the course "Reproducibility Engineering" ("D_REN", also called "RepEng").
The chosen topic is Quantum Computing and Reinforcement Learning (the third suggested topic).
The team consists of Lea Laux and Martin Meilinger.


## Usage

Our Dockerfile offers two ways of building an image of it: with or without GPU.
To build the image with a GPU present, run:
``
docker build -t repro_gpu --build-arg has_gpu=with-gpu .
``
To build the image without the usage of a GPU, therefore CPU only, run:
``
docker build -t repro_cpu --build-arg has_gpu=without-gpu .
``


After building the image, you can decide whether to run all trainings and then generate our report or only the latter.
To create a container that will run all trainings and then generate our report, run:
(with GPU)
``
docker run --name repro_gpu_all -it --runtime=nvidia repro_gpu true
``
(without GPU, so CPU only)
``
docker run --name repro_cpu_all -it repro_cpu true
``

To create a container that only generates our report, run:
(with GPU)
``
docker run --name repro_gpu_report -it --runtime=nvidia repro_gpu false
``
(without GPU, so CPU only)
``
docker run --name repro_cpu_report -it repro_cpu false
``