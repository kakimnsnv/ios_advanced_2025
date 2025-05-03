package main

import (
	"context"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/kakimnsnv/ios_final_back/internal/config"
	"github.com/kakimnsnv/ios_final_back/internal/controller"
	"github.com/kakimnsnv/ios_final_back/internal/db"
	"github.com/kakimnsnv/ios_final_back/internal/logger"
	"github.com/kakimnsnv/ios_final_back/internal/repository"
	"github.com/kakimnsnv/ios_final_back/internal/service"
	"go.uber.org/zap"
)

func main() {
	log := logger.New()
	defer log.Sync()

	cfg := config.New(log)

	mongoDB, mongoClient, collectionNames := db.New(log, cfg.MongoURI, cfg.MongoDB)
	defer func() {
		if err := mongoClient.Disconnect(context.TODO()); err != nil {
			log.Fatal(err.Error())
		}
	}()

	router := gin.Default()

	jwtSvc := service.NewJWTService(cfg.JWTSecret, time.Duration(cfg.JWTDurationInMinutes*int(time.Minute)), time.Duration(cfg.JWTRefreshDurationInMinutes*int(time.Minute)))

	userRepo := repository.NewUserRepo(log, collectionNames, mongoDB)
	userSvc := service.NewUserService(log, userRepo, jwtSvc)

	movieRepo := repository.NewMovieRepo(log, collectionNames, mongoDB)
	movieSvc := service.NewMovieService(log, movieRepo)

	reviewRepo := repository.NewReviewRepo(log, collectionNames, mongoDB)
	reviewSvc := service.NewReviewService(log, reviewRepo)

	ctrl := controller.New(router, log, userSvc, movieSvc, reviewSvc, jwtSvc)
	ctrl.Bind()

	log.Info("Starting server", zap.String("port", cfg.Port))
	if err := router.Run(":" + cfg.Port); err != nil {
		log.Fatal("Failed to start server", zap.Error(err))
	}
}
