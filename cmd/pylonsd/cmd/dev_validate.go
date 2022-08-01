package cmd

import (
	"fmt"

	"github.com/Pylons-tech/pylons/x/pylons/types/v1beta1"
	"github.com/spf13/cobra"
)

func DevValidate() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "validate [path]",
		Short: "Validates all Pylons recipe or cookbook files in the provided path",
		Args:  cobra.ExactArgs(1),
		Run: func(cmd *cobra.Command, args []string) {
			path := args[0]
			ForFiles(path, perCookbook, perRecipe)
		},
	}
	return cmd
}

func perCookbook(path string, _ v1beta1.Cookbook) {
	fmt.Fprintln(Out, path, "is a valid cookbook")
}

func perRecipe(path string, _ v1beta1.Recipe) {
	fmt.Fprintln(Out, path, "is a valid recipe")
}
