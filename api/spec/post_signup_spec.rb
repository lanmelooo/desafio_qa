require_relative "routes/signup"
require_relative "libs/mongo"

describe "POST / signup" do
  context "novo usuario" do
    before(:all) do
      payload = { name: "Pitty", email: "pitty@bol.com.br", password: "pwd123" }
      MongoDB.new.remove_user(payload[:email])

      @result = Signup.new.create(payload)
    end

    it "valida status code" do
      expect(@result.code).to eql 200
    end

    it "valida id do usuário" do
      expect(@result.parsed_response["_id"].length).to eql 24
    end
  end

  context "usuario ja existe" do
    before(:all) do
      # dado que eu tenho um novo usuario
      payload = { name: "Joao da Silva", email: "joao@ig.com.br", password: "pwd123" }
      MongoDB.new.remove_user(payload[:email])

      # e o email desse usuário ja foi cadastro no sistema
      Signup.new.create(payload)

      # quando faço uma requisição par a rota /signup
      @result = Signup.new.create(payload)
    end

    it "deve retornar 409" do
      # então deve retornar 409
      expect(@result.code).to eql 409
    end

    it "deve retornar mensagem" do
      expect(@result.parsed_response["error"]).to eql "Email already exists :("
    end
  end

  context "insira um nome de usuário" do
    before(:all) do
      payload = { name: "", email: "geremias@hotmail.com.br", password: "pwd123" }
      MongoDB.new.remove_user(payload[:email])
      Signup.new.create(payload)
      @result = Signup.new.create(payload)
    end

    it "deve retornar 412" do
      # então deve retornar 412
      expect(@result.code).to eql 412
    end

    it "deve retornar mensagem" do
      expect(@result.parsed_response["error"]).to eql "required name"
    end
  end

  context "insira um email para efetuar o login" do
    before(:all) do
      payload = { name: "LicoLico", email: "", password: "pwd123" }
      MongoDB.new.remove_user(payload[:email])

      Signup.new.create(payload)

      @result = Signup.new.create(payload)
    end

    it "deve retornar 412" do
      # então deve retornar 412
      expect(@result.code).to eql 412
    end

    it "deve retornar mensagem" do
      expect(@result.parsed_response["error"]).to eql "required email"
    end
  end

  context "insira uma senha para efetuar o login" do
    before(:all) do
      payload = { name: "Seu zé", email: "ze@terra.com.br", password: "" }
      MongoDB.new.remove_user(payload[:email])

      Signup.new.create(payload)

      @result = Signup.new.create(payload)
    end

    it "deve retornar 412" do
      # então deve retornar 412
      expect(@result.code).to eql 412
    end

    it "deve retornar mensagem" do
      expect(@result.parsed_response["error"]).to eql "required password"
    end
  end
end

# examples = [
#     {
#       title: "usuario ja existe",
#       payload: payload = { name: "Joao da Silva", email: "joao@ig.com.br", password: "pwd123" },
#       code: 409,
#       error: "Email already exists :(",
#     },
#     {
#       title: "insira um nome de usuário",
#       payload: { name: "", email: "geremias@hotmail.com.br", password: "pwd123" },
#       code: 412,
#       error: "required name",
#     },
#     {
#       title: "insira um email para efetuar o login",
#       payload: { name: "LicoLico", email: "", password: "pwd123" },
#       code: 412,
#       error: "required email",
#     },
#     {
#       title: "insira um email para efetuar o login",
#       payload: { name: "Seu zé", email: "ze@terra.com.br", password: "" },
#       code: 412,
#       error: "required password",
#     },

#   ]

#   examples.each do |e|
#     context "#{e[:title]}" do
#       before(:all) do
#         MongoDB.new.remove_user(payload[:email])
#         Signup.new.create(:payload)
#         @result = Signup.new.create(:payload)
#       end
#     end
#   end
