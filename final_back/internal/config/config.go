package config

import (
	"github.com/ilyakaznacheev/cleanenv"
	"go.uber.org/zap"
)

type Config struct {
	Port                        string `env:"PORT" env-default:"8080"`
	MongoURI                    string `env:"MONGO_URI" env-default:"mongodb://username:password@localhost:27001"`
	MongoDB                     string `env:"MONGO_DB" env-default:"user_service"`
	JWTSecret                   string `env:"JWT_SECRET" env-default:"superrandomparol"`
	JWTDurationInMinutes        int    `env:"JWT_DURATION" env-default:"60"`
	JWTRefreshDurationInMinutes int    `env:"JWT_REFRESH_DURATION" env-default:"1440"`
}

func New(log *zap.Logger) *Config {
	var cfg Config
	if err := cleanenv.ReadEnv(&cfg); err != nil {
		log.Fatal("Failed to load configuration", zap.Error(err))
	}
	return &cfg
}
