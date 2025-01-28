class MersenneTwister:
    def __init__(self, seed):
        self.w, self.n, self.m, self.r = 32, 624, 397, 31  # Parameters for MT19937
        self.a = 0x9908B0DF  # Coefficient for twist
        self.u, self.d = 11, 0xFFFFFFFF  # Tempering parameters
        self.s, self.b = 7, 0x9D2C5680
        self.t, self.c = 15, 0xEFC60000
        self.l = 18
        self.f = 1812433253  # Initialization multiplier

        # Internal state array
        self.MT = [0] * self.n
        self.index = self.n  # Index indicates when a twist is needed
        self.lower_mask = (1 << self.r) - 1  # Lower r bits
        self.upper_mask = (~self.lower_mask) & 0xFFFFFFFF  # Upper (w - r) bits

        # Initialize with the provided seed
        self.seed_mt(seed)

    def seed_mt(self, seed):
        """Initializes the state array with the given seed."""
        self.MT[0] = seed & 0xFFFFFFFF  # Ensure the seed fits in 32 bits
        for i in range(1, self.n):
            self.MT[i] = (self.f * (self.MT[i - 1] ^ (self.MT[i - 1] >> (self.w - 2))) + i) & 0xFFFFFFFF

    def twist(self):
        """Generates the next n values in the sequence."""
        for i in range(self.n):
            x = (self.MT[i] & self.upper_mask) + (self.MT[(i + 1) % self.n] & self.lower_mask)
            xA = x >> 1
            if x % 2 != 0:  # If the least significant bit of x is 1
                xA = xA ^ self.a
            self.MT[i] = self.MT[(i + self.m) % self.n] ^ xA
        self.index = 0

    def extract_number(self):
        """Extracts a number in the range [0, 1)."""
        if self.index >= self.n:
            self.twist()  # Generate new state if needed

        # Get the current number and temper it
        y = self.MT[self.index]
        y = y ^ ((y >> self.u) & self.d)
        y = y ^ ((y << self.s) & self.b)
        y = y ^ ((y << self.t) & self.c)
        y = y ^ (y >> self.l)

        self.index += 1
        return y / 0xFFFFFFFF  # Return a value in the range [0, 1)


# Test the Mersenne Twister implementation
if __name__ == "__main__":
    seed = 5489  # Example seed value
    mt = MersenneTwister(seed)

    print("First 10 random numbers in the range [0, 1):")
    for _ in range(10):
        print(mt.extract_number())

