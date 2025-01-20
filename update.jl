using Pkg

function main()
    Pkg.update()
    println(stdout)
end

(@__MODULE__() == Main) && main()