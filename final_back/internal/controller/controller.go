package controller

import (
	"github.com/gin-gonic/gin"
	"github.com/kakimnsnv/ios_final_back/internal/service"
	"go.uber.org/zap"
)

type controller struct {
	log       *zap.Logger
	usersvc   service.UserService
	router    *gin.Engine
	movieSvc  service.MovieService
	reviewSvc service.ReviewService
	jwtSvc    service.JWTService
}

func New(router *gin.Engine, logger *zap.Logger, usersvc service.UserService, movieSvc service.MovieService, reviewSvc service.ReviewService, jwtSvc service.JWTService) *controller {
	return &controller{
		log:       logger,
		usersvc:   usersvc,
		router:    router,
		movieSvc:  movieSvc,
		reviewSvc: reviewSvc,
		jwtSvc:    jwtSvc,
	}
}

func (c *controller) Bind() {
	c.router.Use(c.AuthenticateMiddleware())
	users := c.router.Group("/users")
	{
		// common
		users.GET("/", c.ListUsers)

		// for user itself
		users.POST("/register", c.RegisterUser)
		users.POST("/login", c.LoginUser)
		users.POST("/refresh", c.RefreshToken)
		users.GET("/me", c.GetMe)
		users.PUT("/me", c.UpdateMe)
		users.DELETE("/me", c.DeleteMe)
		users.GET("/:id", c.GetUser)

		// for moderators and admin
		users.PUT("/:id", c.UpdateUser)
		users.DELETE("/:id", c.DeleteUser)
	}

	movies := c.router.Group("/movies")
	{
		// 	// common
		movies.GET("/", c.ListMovies)
		movies.GET("/:id", c.GetMovie)

		// 	// for moderators and admin
		movies.POST("/", c.CreateMovie)
		movies.PUT("/:id", c.UpdateMovie)
		movies.DELETE("/:id", c.DeleteMovie)
	}

	reviews := c.router.Group("/reviews")
	{
		// common
		reviews.GET("/:movieId", c.ListReviewsByMovieID)
		reviews.GET("/categories", c.ListReviewCategories)
		reviews.PUT("/:id", c.UpdateReview)

		// users own
		reviews.GET("/my", c.ListMyReviews)
		reviews.POST("/", c.CreateReview)

		// 	// for moderators and admin
		reviews.DELETE("/:id", c.DeleteReview)
	}
}
