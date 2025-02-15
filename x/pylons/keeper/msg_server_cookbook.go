package keeper

import (
	"context"

	"github.com/cosmos/cosmos-sdk/telemetry"
	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"

	"github.com/Pylons-tech/pylons/x/pylons/types"
)

func (k msgServer) CreateCookbook(goCtx context.Context, msg *types.MsgCreateCookbook) (*types.MsgCreateCookbookResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)
	// Check if the value already exists
	_, isFound := k.GetCookbook(ctx, msg.Id)
	if isFound {
		return nil, sdkerrors.Wrapf(sdkerrors.ErrInvalidRequest, "ID %v already set", msg.Id)
	}

	cookbook := types.Cookbook{
		Id:           msg.Id,
		Creator:      msg.Creator,
		NodeVersion:  k.EngineVersion(ctx),
		Name:         msg.Name,
		Description:  msg.Description,
		Developer:    msg.Developer,
		Version:      msg.Version,
		SupportEmail: msg.SupportEmail,
		Enabled:      msg.Enabled,
	}

	k.SetCookbook(
		ctx,
		cookbook,
	)

	err := ctx.EventManager().EmitTypedEvent(&types.EventCreateCookbook{
		Creator: cookbook.Creator,
		Id:      cookbook.Id,
	})

	telemetry.IncrCounter(1, "cookbook", "create")

	return &types.MsgCreateCookbookResponse{}, err
}

func (k msgServer) UpdateCookbook(goCtx context.Context, msg *types.MsgUpdateCookbook) (*types.MsgUpdateCookbookResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	// Check if the value exists
	origCookbook, isFound := k.GetCookbook(ctx, msg.Id)
	if !isFound {
		return nil, sdkerrors.Wrapf(sdkerrors.ErrKeyNotFound, "ID %v not set", msg.Id)
	}

	// Check if the msg sender is the same as the current owner
	if msg.Creator != origCookbook.Creator {
		return nil, sdkerrors.Wrap(sdkerrors.ErrUnauthorized, "incorrect owner")
	}

	updatedCookbook := types.Cookbook{
		Id:           msg.Id,
		Creator:      msg.Creator,
		NodeVersion:  k.EngineVersion(ctx),
		Name:         msg.Name,
		Description:  msg.Description,
		Developer:    msg.Developer,
		Version:      msg.Version,
		SupportEmail: msg.SupportEmail,
	}

	modified, err := types.CookbookModified(origCookbook, updatedCookbook)
	if err != nil {
		return nil, err
	}

	if modified {
		k.SetCookbook(ctx, updatedCookbook)
	}

	err = ctx.EventManager().EmitTypedEvent(&types.EventUpdateCookbook{
		OriginalCookbook: origCookbook,
	})

	telemetry.IncrCounter(1, "cookbook", "update")

	return &types.MsgUpdateCookbookResponse{}, err
}
