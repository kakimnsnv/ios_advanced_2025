package service

import (
	"github.com/kakimnsnv/ios_final_back/internal/errs"
	"github.com/kakimnsnv/ios_final_back/internal/models"
	"github.com/kakimnsnv/ios_final_back/internal/repository"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.uber.org/zap"
	"golang.org/x/crypto/bcrypt"
)

type UserService interface {
	ListUsers() ([]*models.User, error)
	CreateUser(req models.CreateUserRequest) (string, string, error)
	LoginUser(req models.UserCredentials) (string, string, error)
	GetUserByID(id *primitive.ObjectID) (*models.User, error)
	UpdateMe(id *primitive.ObjectID, req models.UpdateMeRequest) (*models.User, error)
	DeleteMe(id *primitive.ObjectID) error

	UpdateUser(actorID *primitive.ObjectID, id *primitive.ObjectID, req models.UpdateUserRequest) (*models.User, error)
	DeleteUser(actorID *primitive.ObjectID, id *primitive.ObjectID) error
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

	err = bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password))
	if err != nil {
		s.log.Error("failed to compare password", zap.Error(err))
		return "", "", err
	}

	return s.jwtSvc.CreateJWT(*user.ID, user.Roles)
}

func (s *userSvc) GetUserByID(id *primitive.ObjectID) (*models.User, error) {
	user, err := s.repo.GetUserByID(id)
	if err != nil {
		s.log.Error("failed to get user by ID", zap.Error(err))
		return nil, err
	}
	return user, nil
}

func (s *userSvc) UpdateMe(id *primitive.ObjectID, req models.UpdateMeRequest) (*models.User, error) {
	user, err := s.repo.GetUserByID(id)
	if err != nil {
		s.log.Error("failed to get user by ID", zap.Error(err))
		return nil, err
	}

	if req.Username != nil {
		user.Username = *req.Username
	}

	if req.Email != nil {
		user.Email = *req.Email
	}

	return s.repo.UpdateUser(id, user)
}

func (s *userSvc) DeleteMe(id *primitive.ObjectID) error {
	err := s.repo.DeleteUser(id)
	if err != nil {
		s.log.Error("failed to delete user", zap.Error(err))
		return err
	}
	return nil
}

func (s *userSvc) ListUsers() ([]*models.User, error) {
	users, err := s.repo.ListUsers()
	if err != nil {
		s.log.Error("failed to list users", zap.Error(err))
		return nil, err
	}
	return users, nil
}

func (s *userSvc) UpdateUser(actorID *primitive.ObjectID, id *primitive.ObjectID, req models.UpdateUserRequest) (*models.User, error) {
	actor, err := s.repo.GetUserByID(actorID)
	if err != nil {
		s.log.Error("failed to get actor by ID", zap.Error(err))
		return nil, err
	}

	user, err := s.repo.GetUserByID(id)
	if err != nil {
		s.log.Error("failed to get user by ID", zap.Error(err))
		return nil, err
	}

	if !HasPermission(actor, ResourceUser, ActionUpdate, user) {
		s.log.Error("user does not have permission to update user", zap.Error(err))
		return nil, errs.Forbidden
	}

	return s.repo.UpdateUser(id, user)
}

func (s *userSvc) DeleteUser(actorID *primitive.ObjectID, id *primitive.ObjectID) error {
	actor, err := s.repo.GetUserByID(actorID)
	if err != nil {
		s.log.Error("failed to get actor by ID", zap.Error(err))
		return err
	}

	user, err := s.repo.GetUserByID(id)
	if err != nil {
		s.log.Error("failed to get user by ID", zap.Error(err))
		return err
	}

	if !HasPermission(actor, ResourceUser, ActionUpdate, user) {
		s.log.Error("user does not have permission to update user", zap.Error(err))
		return errs.Forbidden
	}

	return s.repo.DeleteUser(id)
}
