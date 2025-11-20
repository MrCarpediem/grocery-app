import Banner from "../components/Banner";
import BestSeller from "../components/BestSeller";
import Category from "../components/Category";
import Newsletter from "../components/Newsletter.jsx";

const Home = () => {
  return (
    <div className="mt-10">
      <Banner />
      <Category />
      <BestSeller />
      <Newsletter />
    </div>
  );
};
export default Home;
