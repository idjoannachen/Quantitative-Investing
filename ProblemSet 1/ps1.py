from scipy.stats import t, jarque_bera
import statsmodels.formula.api as smf
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import os


# define directories
base_dir = "/MGT_595/hw1"

# load data
df = pd.read_excel(os.path.join(base_dir, "Problem_Set1.xlsx"), index_col="date",
                   skiprows=5)
df.index = pd.to_datetime(df.index, format="%Y%m")
df = df.drop(["Unnamed: 51"], axis=1)
df = df.rename(columns={"Market (Value Weighted Index)": "Market"})

# 1.a

# calculate values
mv = pd.concat([df.iloc[:,:5].mean(axis=1).aggregate(["mean", "std"]),
                df.iloc[:,:10].mean(axis=1).aggregate(["mean", "std"]),
                df.iloc[:,:25].mean(axis=1).aggregate(["mean", "std"]),
                df.iloc[:,:50].mean(axis=1).aggregate(["mean", "std"])],
               axis=1)
mv.columns = [5, 10, 25, 50]
print(mv)
mv.to_csv(os.path.join(base_dir, "1a_tab.csv"))
mv = mv.T

# plot std
plt.plot(mv["std"])
plt.xlabel("Number of stocks in portfolio")
plt.ylabel("Estimated standard deviation")
plt.savefig(os.path.join(base_dir, "1a_plot.png"))
plt.clf()

# 1.b
tv_comp = pd.Series([df.iloc[:,:5].mean(axis=1).var(),
                     df.iloc[:,:10].mean(axis=1).var(),
                     df.iloc[:,:25].mean(axis=1).var(),
                     df.iloc[:,:50].mean(axis=1).var()])
v_comp = pd.Series([df.var().iloc[:5].mean() / 5.,
                    df.var().iloc[:10].mean() / 10.,
                    df.var().iloc[:25].mean() / 25.,
                    df.var().iloc[:50].mean() / 50.])
cov_comp = tv_comp - v_comp
v_df = pd.DataFrame({"Sample Variance": tv_comp,
                     "Var Component": v_comp,
                     "Cov Component": cov_comp})
v_df.index = [5, 10, 25, 50]
v_df.index.name = "N"
v_df = v_df.T
print(v_df)
v_df.to_csv(os.path.join(base_dir, "1b_tab.csv"))
v_df = v_df.T

# plot proportion
v_prop = v_df["Var Component"] / v_df["Sample Variance"]
plt.plot(v_prop)
plt.xlabel("Number of stocks in portfolio")
plt.ylabel("Variance proportion")
plt.savefig(os.path.join(base_dir, "1b_varcomp.png"))
plt.clf()

# plot decomp
plt.plot(v_df["Sample Variance"], label="Sample Variance")
plt.plot(v_df["Var Component"], label="Var Component")
plt.plot(v_df["Cov Component"], label="Cov Component")
plt.xlabel("Number of stocks in portfolio")
plt.legend()
plt.savefig(os.path.join(base_dir, "1b_decomp.png"))
plt.clf()

# 1.d
tstat = mv["mean"] / (mv["std"] / np.sqrt(df.shape[0]))
pval = (1. - t.cdf(tstat, df.shape[0] - 1)) * 2.
tstat = pd.DataFrame({"t Stat": tstat,
                      "p-value": pval})
tstat.index = [5, 10, 25, 50]
tstat.index.name = "N"
tstat = tstat.T
print(tstat)
tstat.to_csv(os.path.join(base_dir, "1d_tab.csv"))

# 1.e
agg = pd.DataFrame({"CTL": df["CTL"],
                    "eqw": df.iloc[:,:50].mean(axis=1),
                    "Market": df["Market"]})
aggd = agg.aggregate(["mean", "std", "max", "min",
                      "skew", "kurt"]).T
aggd["range"] = aggd["max"] - aggd["min"]
aggd["stu_range"] = aggd["range"] / aggd["std"]
aggd["jb_pval"] = pd.Series([jarque_bera(agg[c])[1]
                             for c in agg.columns],
                            index=agg.columns)
aggd = aggd.T
print(aggd)
aggd.to_csv(os.path.join(base_dir, "1e_tab.csv"))

# 1.f
coef_dict = {}
for c in df.columns[:10]:
    mod = smf.ols("%s ~ Market" % c, data=df)
    fit = mod.fit()
    vals = fit.params
    vals["r2"] = fit.rsquared
    mod = smf.ols("%s ~ Market - 1" % c, data=df)
    fit = mod.fit()
    vals["Market no int"] = fit.params["Market"]
    coef_dict[c] = vals
coefs = pd.DataFrame(coef_dict)
coefs.to_csv(os.path.join(base_dir, "1f_beta.csv"))

# 2.a
vol = pd.DataFrame({"CSCO_exp": df["CSCO"].expanding().std(),
                    "CSCO_12m": df["CSCO"].rolling(12).std(),
                    "mkt_exp": df["Market"].expanding().std(),
                    "mkt_12m": df["Market"].rolling(12).std()})
vol = vol.dropna()

# plot CSCO
plt.plot(vol["CSCO_exp"], label="Expanding Window")
plt.plot(vol["CSCO_12m"], label="Rolling 12 Month Window")
plt.title("CSCO Volatility")
plt.legend()
plt.savefig(os.path.join(base_dir, "2a_CSCO.png"))
plt.clf()

# plot Market
plt.plot(vol["mkt_exp"], label="Expanding Window")
plt.plot(vol["mkt_12m"], label="Rolling 12 Month Window")
plt.title("Market Volatility")
plt.legend()
plt.savefig(os.path.join(base_dir, "2a_mkt.png"))
plt.clf()

# 2.b
exp_param_l = []
rll_param_l = []
exp_se_l = []
rll_se_l = []
for t in range(12, df.shape[0]):

    df_texp = df.iloc[:t,:]
    df_trll = df.iloc[t-12:t,:]

    modexp = smf.ols("CSCO ~ Market", data=df_texp)
    fitexp = modexp.fit()
    exp_param_l.append(fitexp.params["Market"])
    exp_se_l.append(fitexp.HC0_se["Market"])

    modrll = smf.ols("CSCO ~ Market", data=df_trll)
    fitrll = modrll.fit()
    rll_param_l.append(fitrll.params["Market"])
    rll_se_l.append(fitrll.HC0_se["Market"])

beta_df = pd.DataFrame({"beta_exp": exp_param_l,
                        "exp_se": exp_se_l,
                        "beta_roll": rll_param_l,
                        "roll_se": rll_se_l},
                        index=df.index[12:])
beta_df.index.name = "date"

# plot beta
plt.plot(beta_df["beta_roll"], label="Rolling 12 Window", color="b")
plt.plot(beta_df["beta_exp"], label="Expanding Window", color="r")
plt.xlabel("Date")
plt.ylabel("Beta")
plt.legend()
plt.savefig(os.path.join(base_dir, "2b_beta.png"))
plt.clf()

# plot beta + 1SE
plt.plot(beta_df["beta_roll"], label="Rolling 12 Window", color="b")
plt.plot(beta_df["beta_roll"] + 2 * beta_df["roll_se"],
         color="b", linestyle="--")
plt.plot(beta_df["beta_roll"] - 2 * beta_df["roll_se"],
         color="b", linestyle="--")
plt.plot(beta_df["beta_exp"], label="Expanding Window", color="r")
plt.plot(beta_df["beta_exp"] + 2 * beta_df["exp_se"],
         color="r", linestyle="--")
plt.plot(beta_df["beta_exp"] - 2 * beta_df["exp_se"],
         color="r", linestyle="--")
plt.xlabel("Date")
plt.ylabel("Beta")
plt.legend()
plt.savefig(os.path.join(base_dir, "2b_beta_ci.png"))
plt.clf()
