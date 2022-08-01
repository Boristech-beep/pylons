package keeper_test

import (
	sdk "github.com/cosmos/cosmos-sdk/types"

	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"

	"github.com/Pylons-tech/pylons/x/pylons/keeper"
	"github.com/Pylons-tech/pylons/x/pylons/types/v1beta1"
)

func (suite *IntegrationTestSuite) TestTradeMsgServerCreateSimple() {
	k := suite.k
	ctx := suite.ctx
	require := suite.Require()

	wctx := sdk.WrapSDKContext(ctx)
	srv := keeper.NewMsgServerImpl(k)

	creator := v1beta1.GenTestBech32FromString("creator")
	for i := 0; i < 5; i++ {
		resp, err := srv.CreateTrade(wctx, &v1beta1.MsgCreateTrade{
			Creator:     creator,
			CoinInputs:  nil,
			ItemInputs:  nil,
			CoinOutputs: sdk.Coins{},
			ItemOutputs: nil,
			ExtraInfo:   "",
		})
		require.NoError(err)
		require.Equal(i, int(resp.Id))
	}
}

func (suite *IntegrationTestSuite) TestTradeMsgServerCreateInvalidCoinInputs() {
	k := suite.k
	ctx := suite.ctx
	require := suite.Require()

	wctx := sdk.WrapSDKContext(ctx)
	srv := keeper.NewMsgServerImpl(k)

	numTests := 5
	items := createNItem(k, ctx, numTests, true)

	coinInputs := make([]v1beta1.CoinInput, 0)
	coinInputs = append(coinInputs, v1beta1.CoinInput{Coins: sdk.Coins{sdk.Coin{Denom: "test", Amount: sdk.NewInt(0)}}})

	for i := 0; i < 5; i++ {
		_, err := srv.CreateTrade(wctx, &v1beta1.MsgCreateTrade{
			Creator:     items[i].Owner,
			CoinInputs:  coinInputs,
			ItemInputs:  nil,
			CoinOutputs: sdk.Coins{},
			ItemOutputs: []v1beta1.ItemRef{{CookbookId: items[i].CookbookId, ItemId: items[i].Id}},
			ExtraInfo:   "extraInfo",
		})
		require.ErrorIs(err, sdkerrors.ErrInvalidCoins)
	}
}

func (suite *IntegrationTestSuite) TestTradeMsgServerCancel() {
	k := suite.k
	ctx := suite.ctx
	require := suite.Require()

	wctx := sdk.WrapSDKContext(ctx)
	srv := keeper.NewMsgServerImpl(k)
	creator := v1beta1.GenTestBech32FromString("creator")

	for _, tc := range []struct {
		desc    string
		request *v1beta1.MsgCancelTrade
		err     error
	}{
		{
			desc:    "Completed",
			request: &v1beta1.MsgCancelTrade{Creator: creator, Id: 0},
		},
		{
			desc:    "Unauthorized",
			request: &v1beta1.MsgCancelTrade{Creator: "B", Id: 1},
			err:     sdkerrors.ErrUnauthorized,
		},
		{
			desc:    "KeyNotFound",
			request: &v1beta1.MsgCancelTrade{Creator: creator, Id: 10},
			err:     sdkerrors.ErrKeyNotFound,
		},
	} {
		tc := tc
		suite.Run(tc.desc, func() {
			_, err := srv.CreateTrade(wctx, &v1beta1.MsgCreateTrade{
				Creator:     creator,
				CoinInputs:  nil,
				ItemInputs:  nil,
				CoinOutputs: sdk.Coins{},
				ItemOutputs: nil,
				ExtraInfo:   "",
			})
			require.NoError(err)
			_, err = srv.CancelTrade(wctx, tc.request)
			if tc.err != nil {
				require.ErrorIs(err, tc.err)
			} else {
				require.NoError(err)
			}
		})
	}
}
