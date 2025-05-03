package service

import (
	"github.com/kakimnsnv/ios_final_back/internal/models"
	"github.com/kakimnsnv/ios_final_back/internal/repository"
	"go.uber.org/zap"
	"golang.org/x/crypto/bcrypt"
)

type UserService interface {
	CreateUser(req models.CreateUserRequest) (string, string, error)
	LoginUser(req models.UserCredentials) (string, string, error)
}

type userSvc struct {
	log    *zap.Logger
	repo   repository.UserRepo
	jwtSvc JWTService
}

func NewUserService(log *zap.Logger, repo repository.UserRepo, jwtSvc JWTService) UserService {
	return &userSvc{
		log:    log,
		repo:   repo,
		jwtSvc: jwtSvc,
	}
}

// user, err := s.repo.GetUserByID(userID)
// 	if err != nil {
// 		s.log.Error("failed to get user by ID", zap.Error(err))
// 		return "", "", err
// 	}

// 	if !HasPermission(user, ResourceUser, ActionCreate, nil) {
// 		s.log.Error("user does not have permission to create user")
// 		return "", "", errs.Forbidden
// 	}

func (s *userSvc) CreateUser(req models.CreateUserRequest) (string, string, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		s.log.Error("failed to hash password", zap.Error(err))
		return "", "", err
	}

	user := &models.User{
		Username:     req.Username,
		PasswordHash: hash,
		Email:        req.Email,
		Roles: []models.Role{
			RoleUser,
		},
	}
	id, err := s.repo.CreateUser(user)
	if err != nil {
		s.log.Error("failed to create user", zap.Error(err))
		return "", "", err
	}

	return s.jwtSvc.CreateJWT(id, user.Roles)
}

func (s *userSvc) LoginUser(req models.UserCredentials) (string, string, error) {
	user, err := s.repo.GetUserByUsername(req.Username)
	if err != nil {
		s.log.Error("failed to get user by username", zap.Error(err))
		return "", "", err
	}

	bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password))

	user := &models.User{
		Username:     req.Username,
		PasswordHash: hash,
		Email:        req.Email,
		Roles: []models.Role{
			RoleUser,
		},
	}
	id, err := s.repo.CreateUser(user)
	if err != nil {
		s.log.Error("failed to create user", zap.Error(err))
		return "", "", err
	}

	return s.jwtSvc.CreateJWT(id, user.Roles)
}
