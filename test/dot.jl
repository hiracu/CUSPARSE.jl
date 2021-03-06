using CUSPARSE
using CUDArt
using Base.Test

m = 25
n = 35
k = 10
blockdim = 5

#############
# test_doti #
#############

function test_doti(elty)
    x = sparsevec(rand(1:m,k), rand(elty,k), m)
    y = rand(elty,m)
    d_x = CudaSparseMatrixCSC(x)
    d_y = CudaArray(y)
    ddot = CUSPARSE.doti(d_x,d_y,'O')
    #compare
    dot = zero(elty)
    for i in 1:length(x.nzval)
        dot += x.nzval[i] * y[x.rowval[i]]
    end
    @test_approx_eq(ddot, dot)
end

##############
# test_dotci #
##############

function test_dotci(elty)
    x = sparsevec(rand(1:m,k), rand(elty,k), m)
    y = rand(elty,m)
    d_x = CudaSparseMatrixCSC(x)
    d_y = CudaArray(y)
    ddot = CUSPARSE.dotci(d_x,d_y,'O')
    #compare
    dot = zero(elty)
    for i in 1:length(x.nzval)
        dot += conj(x.nzval[i]) * y[x.rowval[i]]
    end
    @test_approx_eq(ddot, dot)
end

types = [Float32,Float64,Complex64,Complex128]
for elty in types
    tic()
    test_doti(elty)
    println("doti took ", toq(), " for ", elty)
end
types = [Complex64,Complex128]
for elty in types
    tic()
    test_dotci(elty)
    println("dotci took ", toq(), " for ", elty)
end
