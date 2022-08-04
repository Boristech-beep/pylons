import { Meteor } from "meteor/meteor";
import { withTracker } from "meteor/react-meteor-data";
import { Recipes } from "/imports/api/recipes/recipes.js";
import EaselBuy from "./EaselBuy.jsx";

export default HomeContainer = withTracker((props) => {
  return EaselBuy;
  let recipesHandle;
  let loading = true;
  var name = "";
  var description = "";
  var img = "";
  var url = props.url;
  var price = "0 Pylon";
  var selectedRecipe = null;
  recipe_id = props.recipe_id;
  
  console.log(props)

  if (Meteor.isClient) {
    recipesHandle = Meteor.subscribe("recipes.list", recipe_id);
    loading = !recipesHandle.ready();
  }

  if (Meteor.isServer || !loading) {
    selectedRecipe = Recipes.findOne({ ID: recipe_id });
  } else {
    selectedRecipe = Recipes.findOne({ ID: recipe_id });
  }

  if (selectedRecipe != null) {
    name = selectedRecipe.name;
    description = selectedRecipe.description;
    const coin_inputs = selectedRecipe.coin_inputs;
    
    if (coin_inputs.length > 0) {
      if (coin_inputs[0].coins[0].denom == "USD") {
        price =
          Math.floor(coin_inputs[0].coins[0].amount / 100) +
          "." +
          (coin_inputs[0].coins[0].amount % 100) +
          " " +
          coin_inputs[0].coins[0].denom;
      } else {
        price =
          coin_inputs[0].coins[0].amount + " " + coin_inputs[0].coins[0].denom;
      }
    }
    const entries = selectedRecipe.entries;
    if (entries != null) {
      const item_outputs = entries.item_outputs;
      if (item_outputs.length > 0) {
        let strings = item_outputs[0].strings;
        for (i = 0; i < strings.length; i++) {
          try {
            if (
              (strings[i].key =
                "NFT_URL" && strings[i].value.indexOf("http") >= 0)
            ) {
              img = strings[i].value;
              break;
            }
          } catch (e) {
            console.log("strings[i].value", e);
            break;
          }
        }
      }
    }
  }
  console.log({
    name,
    description,
    price,
    img: img,
    url: url,
  })
  return {
    name,
    description,
    price,
    img: img,
    url: url,
  };
})(EaselBuy);
