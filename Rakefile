task :start do
    sh('npm start')
    # Rake::Task[:generate_elm].invoke
    # Rake::Task[:elm].invoke
end


task :elm do
    sh("elm make src/main.elm")
end

task :generate_elm do
    sh("npm run elm-graphql http://localhost:4000/graphql --base Stapi --output src")
    Rake::Task[:elm].invoke
end