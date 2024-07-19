# TimeCapsule: A Secure and Scalable Time Travel Application

## Overview

TimeCapsule is a web application that allows users to store and manage their personal memories, milestones, and historical events. It leverages a microservice architecture with a secure authentication service and a robust API gateway.

## Project Structure

The project is organized into three main repositories:

**1. `infra-repo` (Infrastructure):**

- Contains Docker Compose files for deploying Kafka, MongoDB, and PostgreSQL.
- Provides the necessary infrastructure for the authentication and memory services.

**2. `memory-service-repo` (Memory Service):**

- Contains the core logic for managing memories, media, and comments.
- Uses PostgreSQL for persistent storage and Kafka for asynchronous operations.

**3. `auth-service-repo` (Authentication Service):**

- Provides secure user registration, login, and token generation.
- Uses PostgreSQL for user data, Redis for OTP storage, and JWTs for authentication.

**4. `api-gateway-repo` (API Gateway):**

- Acts as a central entry point for external clients.
- Routes requests to the appropriate services (authentication and memory).
- Handles authentication, authorization, and other cross-cutting concerns.

## Technologies Used

- **Go:** The primary programming language for all services.
- **Gin:** The web framework used for building the API gateway.
- **PostgreSQL:** The database used for storing user data, memories, media, and comments.
- **MongoDB:** The database used for storing historical events (in the Timeline service).
- **Redis:** Used for caching OTP codes in the authentication service.
- **Kafka:** Used for asynchronous communication between services.
- **JWT:** JSON Web Tokens are used for authentication and authorization.
- **Swagger (OpenAPI):** Used for API documentation.
- **Docker:** Used for containerizing and deploying services.
- **Docker Compose:** Used for managing the multi-container setup.

## Getting Started

**1. Clone the Repositories:**

- Clone the `infra-repo`, `memory-service-repo`, and `auth-service-repo` repositories from their respective locations.

**2. Set up Environment Variables:**

- Create a `.env` file in the root directory of each repository.
- Set the following environment variables (replace placeholders with your actual values):

  ```
  # General Configuration
  ENVIRONMENT=development # Or production, etc.
  HTTP_PORT=:8080 # Port for the API gateway

  # PostgreSQL Configuration
  POSTGRES_USER=postgres
  POSTGRES_PASSWORD=root
  POSTGRES_HOST=postgres # Hostname of the PostgreSQL container
  POSTGRES_PORT=5432
  POSTGRES_DB=memory

  # Redis Configuration
  REDIS_ADDRESS=localhost:6379
  REDIS_PASSWORD=
  REDIS_DB=0

  # JWT Configuration
  JWT_SECRET_KEY=your_secret_key # **IMPORTANT: Change this in production!**
  JWT_EXPIRY=60 # Token expiry in minutes

  # Email Configuration (if using email OTP)
  EMAIL_SENDER=your_email@example.com
  EMAIL_PASSWORD=your_email_password
  EMAIL_HOST=smtp.example.com
  EMAIL_PORT=587
  EMAIL_FROM_ADDRESS=your_email@example.com

  # Kafka Configuration
  KAFKA_BROKERS=kafka:9092 # Hostname and port of the Kafka broker
  KAFKA_MILESTONE_TOPIC=milestone_topic
  KAFKA_MEMORY_TOPIC=memory_topic
  KAFKA_COMMENT_TOPIC=comment_topic
  KAFKA_CUSTOM_EVENT_TOPIC=custom_event_topic
  KAFKA_HISTORICAL_EVENT_TOPIC=historical_event_topic
  KAFKA_MEDIA_TOPIC=media_topic
  ```

**3. Build and Run the Infrastructure:**

- Navigate to the `time-capsule-project` directory.
- Run `docker-compose up -d` to start Kafka, MongoDB, PostgreSQL, and ZooKeeper in the background.

**4. Build and Run the Memory Service:**

- Navigate to the `timeline-service-repo` directory.
- Run `docker-compose up -d` to start the timeline service container.

**5. Build and Run the Authentication Service:**

- Navigate to the `auth-service-repo` directory.
- Run `docker-compose up -d` to start the authentication service container.

**6. Build and Run the Memory Service:**

- Navigate to the `memory-service-repo` directory.
- Run `docker-compose up -d` to start the memory service container.

**7. Build and Run the API Gateway:**

- Navigate to the `api-gateway-repo` directory.
- Run `docker-compose up -d` to start the API gateway container.

**8. Access the API Gateway:**

- Once the API gateway is running, you can access it at `http://localhost:8080/swagger/index.html` to view the Swagger UI documentation.

## Authentication Service

### Project Structure

### API Endpoints

- **POST /auth/register:** Registers a new user and sends an OTP to their email for verification.
- **POST /auth/verify-otp:** Verifies the OTP sent to the user's email during registration.
- **POST /auth/login:** Authenticates a user and issues a JWT token.
- **GET /auth/validate:** Validates a JWT token and returns the user ID and role.
- **GET /users:** Retrieves a list of all users.
- **GET /users/{userId}:** Retrieves a user by their ID.
- **PUT /users/{userId}:** Updates a user's information.
- **DELETE /users/{userId}:** Deletes a user by their ID.

### Database Migrations

```sql
-- Create the "users" table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    date_of_birth DATE,
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create the "memories" table
CREATE TABLE memories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    tags TEXT[],
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    place_name VARCHAR(255),
    privacy VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create the "media" table
CREATE TABLE media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    memory_id UUID,
    type VARCHAR(10) NOT NULL,
    url VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (memory_id) REFERENCES memories(id) ON DELETE CASCADE
);

-- Create the "comments" table
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    memory_id UUID,
    user_id UUID NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (memory_id) REFERENCES memories(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create the "milestones" table
CREATE TABLE milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create the "custom_events" table
CREATE TABLE custom_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

```
